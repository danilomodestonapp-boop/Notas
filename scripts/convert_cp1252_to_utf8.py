from pathlib import Path


def convert(path: Path):
    if not path.exists():
        print(f"SKIP missing: {path}")
        return
    b = path.read_bytes()
    # First, try utf-8
    try:
        text = b.decode('utf-8')
        # detect mojibake sequences (Ã etc.)
        if 'Ã' in text:
            need_cp1252 = True
        else:
            need_cp1252 = False
        if not need_cp1252:
            print(f"Already utf8: {path}")
            # ensure BOM
            path.write_bytes(b"\xef\xbb\xbf" + text.encode('utf-8'))
            return
    except Exception:
        need_cp1252 = True

    # If we reach here, try cp1252 -> utf8
    try:
        text = b.decode('cp1252')
        path.write_bytes(b"\xef\xbb\xbf" + text.encode('utf-8'))
        print(f"Converted CP1252->UTF8: {path}")
    except Exception as e:
        # fallback to latin-1 which maps all bytes
        try:
            text = b.decode('latin-1')
            path.write_bytes(b"\xef\xbb\xbf" + text.encode('utf-8'))
            print(f"Converted latin-1->UTF8: {path}")
        except Exception as e2:
            print(f"Failed to convert {path}: {e} / {e2}")


if __name__ == '__main__':
    files = [
        Path('tarefas-concluidas.md'),
        Path('resumo-tarefas-2026-06-15.md')
    ]
    for f in files:
        convert(f)
