"""Run: python3 -m unittest discover -s docs/tests -v"""
import json
from pathlib import Path
import subprocess
import sys
import tempfile
import unittest

SCRIPT = Path(__file__).resolve().parents[2] / 'dot_local/bin/executable_obsidian-sync-plugins'


class SyncTest(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.addCleanup(self.tmp.cleanup)
        self.root = Path(self.tmp.name)
        for name in ('', 'child'):
            config = self.root / name / '.obsidian'
            config.mkdir(parents=True)
            (config / 'community-plugins.json').write_text('[]')

    def plugin(self, vault, plugin, version='1.0.0', code='code'):
        config = self.root / vault / '.obsidian'
        path = config / 'plugins' / plugin
        path.mkdir(parents=True, exist_ok=True)
        (path / 'manifest.json').write_text(json.dumps({'id': plugin, 'version': version}))
        (path / 'main.js').write_text(code)
        enabled = json.loads((config / 'community-plugins.json').read_text())
        if plugin not in enabled:
            enabled.append(plugin)
        (config / 'community-plugins.json').write_text(json.dumps(enabled))
        return path

    def run_sync(self, *flags):
        return subprocess.run([sys.executable, str(SCRIPT), '--root', str(self.root),
                               '--vault', 'child', *flags], capture_output=True, text=True)

    def test_union_latest_preserves_settings_and_is_idempotent(self):
        primary = self.plugin('', 'one')
        self.plugin('child', 'one', '2.0.0', 'newer')
        self.plugin('child', 'two')
        (primary / 'data.json').write_text('{"private":"unchanged"}')
        result = self.run_sync('--apply')
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual((primary / 'main.js').read_text(), 'newer')
        self.assertEqual((primary / 'data.json').read_text(), '{"private":"unchanged"}')
        self.assertFalse((self.root / 'child/.obsidian/plugins/one/data.json').exists())
        for vault in ('', 'child'):
            self.assertEqual(json.loads((self.root / vault / '.obsidian/community-plugins.json').read_text()), ['one', 'two'])
        self.assertTrue(list((self.root / '.vault-tools/backups').glob('*/changes.json')))
        self.assertIn('0 file changes', self.run_sync().stdout)

    def test_preview_does_not_write(self):
        self.plugin('', 'one')
        before = sorted(str(p.relative_to(self.root)) for p in self.root.rglob('*'))
        self.assertEqual(self.run_sync().returncode, 0)
        self.assertEqual(before, sorted(str(p.relative_to(self.root)) for p in self.root.rglob('*')))

    def test_conflicting_builds_stop_before_writes(self):
        self.plugin('', 'one', code='first')
        self.plugin('child', 'one', code='different')
        result = self.run_sync('--apply')
        self.assertNotEqual(result.returncode, 0)
        self.assertIn('Conflicting builds', result.stderr)
        self.assertFalse((self.root / '.vault-tools').exists())

    def test_broken_symlink_is_backed_up_and_replaced(self):
        self.plugin('', 'one')
        child = self.root / 'child/.obsidian/plugins/one'
        child.mkdir(parents=True)
        (child / 'main.js').symlink_to(self.root / 'missing-file')
        result = self.run_sync('--apply')
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertFalse((child / 'main.js').is_symlink())
        backups = list((self.root / '.vault-tools/backups').glob('*/child/.obsidian/plugins/one/main.js'))
        self.assertEqual(len(backups), 1)
        self.assertTrue(backups[0].is_symlink())

    def test_missing_vault_fails_without_creating_it(self):
        result = subprocess.run([sys.executable, str(SCRIPT), '--root', str(self.root),
                                 '--vault', 'missing', '--apply'], capture_output=True, text=True)
        self.assertNotEqual(result.returncode, 0)
        self.assertFalse((self.root / 'missing').exists())


if __name__ == '__main__':
    unittest.main()
