import os
import re
from pathlib import Path


INSTRUCCIONES = Path("RefactorX") / "instrucciones.txt"
OUTPUT_PATH = Path("/mnt/c/Tmp/Doc/menu.md")


def win_to_posix(p: str) -> str:
    p = p.strip().replace("\\", "/")
    if re.match(r"^[A-Za-z]:/", p):
        drive = p[0].lower()
        rest = p[2:]
        return f"/mnt/{drive}{rest if rest.startswith('/') else '/' + rest}"
    return p


def read_instrucciones() -> list[tuple[str, str]]:
    # Returns list of (system_name, posix_path)
    text = INSTRUCCIONES.read_text(encoding="utf-8", errors="ignore")
    lines = [l.rstrip("\r\n") for l in text.splitlines()]

    # Collect rutas after a line exactly 'Rutas'
    rutas: list[str] = []
    started = False
    for ln in lines:
        if not started:
            if ln.strip().lower() == "rutas":
                started = True
            continue
        if ln.strip() == "":
            continue
        rutas.append(ln.strip())

    # Map system name to last component of ruta
    pairs: list[tuple[str, str]] = []
    for ruta in rutas:
        # system name = last folder name (after last backslash)
        last = ruta.strip().rstrip("/\\").split("\\")[-1]
        sysname = last
        posix = win_to_posix(ruta)
        pairs.append((sysname, posix))
    return pairs


class MenuNode:
    def __init__(self, caption: str, name: str | None = None):
        self.caption = caption
        self.name = name
        self.onclick: str | None = None
        self.action: str | None = None
        self.target_form_class: str | None = None  # p.ej., TfrmX
        self.target_form_var: str | None = None    # p.ej., frmX
        self.open_mode: str | None = None          # Show | ShowModal | None
        self.children: list["MenuNode"] = []

    def add(self, child: "MenuNode"):
        self.children.append(child)

    def is_leaf(self) -> bool:
        return len(self.children) == 0


def clean_caption(s: str) -> str:
    s = s.replace("&&", "&")
    s = s.replace("&", "")
    return s.strip()


def parse_dfm_menu(filepath: Path) -> list[MenuNode]:
    # Devuelve lista combinada de nodos detectados en el DFM:
    # - TMainMenu/TMenuItem
    # - TMenuItem sueltos (raíz)
    # - JVCL (TJvOutlookBar/TJvLookOut/TPageControl)
    try:
        raw = filepath.read_text(encoding="utf-8")
    except UnicodeDecodeError:
        raw = filepath.read_text(encoding="latin-1", errors="ignore")
    except Exception:
        return []

    # Prefiltro: dfm con contenido de formularios
    if "object" not in raw:
        return []

    lines = raw.splitlines()
    # Find assigned Menu id if present at form root
    form_menu_id = None
    for i in range(min(200, len(lines))):
        m = re.search(r"\bMenu\s*=\s*(\w+)", lines[i])
        if m:
            form_menu_id = m.group(1)
            break

    nodes: list[MenuNode] = []
    stack: list[MenuNode] = []
    in_menu = False
    current_object_name = None

    for line in lines:
        # Enter TMainMenu object
        m_obj = re.match(r"\s*object\s+(\w+)\s*:\s*TMainMenu\b", line)
        if m_obj:
            name = m_obj.group(1)
            if form_menu_id is None or form_menu_id == name or not in_menu:
                # Start parsing this menu
                in_menu = True
                current_object_name = name
            continue

        if not in_menu:
            continue

        # New menu item
        m_item = re.match(r"\s*object\s+(\w+)\s*:\s*TMenuItem\b", line)
        if m_item:
            node = MenuNode("")
            if stack:
                stack[-1].add(node)
            else:
                nodes.append(node)
            stack.append(node)
            continue

        # Caption assignment
        m_cap = re.match(r"\s*Caption\s*=\s*'([^']*)'", line)
        if m_cap and stack:
            stack[-1].caption = clean_caption(m_cap.group(1))
            continue

        # End of an object block
        if re.match(r"\s*end\b", line):
            if stack:
                stack.pop()
                continue
            else:
                # end of TMainMenu
                in_menu = False
                current_object_name = None
                # do not break; there might be more menus, but we keep the first meaningful one
                continue

    # 1) TMenuItem bajo TMainMenu
    if form_menu_id is not None:
        # ya se parsea bajo el bloque TMainMenu en el bucle superior
        pass

    # 2) TMenuItem sueltos (y sus Items = <...>)
    roots: list[MenuNode] = parse_root_menuitems(lines)
    if roots:
        nodes.extend(roots)

    # 3) JVCL Outlook/LookOut y PageControl
    jv_nodes = parse_jv_components(lines)
    if jv_nodes:
        nodes.extend(jv_nodes)

    return prune_tree(nodes)


def parse_root_menuitems(lines: list[str]) -> list[MenuNode]:
    roots: list[MenuNode] = []
    stack: list[MenuNode] = []
    # Simple parser de objetos TMenuItem en raíz y sus Captions; además buscar "Items = <...>"
    for i, line in enumerate(lines):
        m_item = re.match(r"\s*object\s+(\w+)\s*:\s*TMenuItem\b", line)
        if m_item:
            node = MenuNode("", name=m_item.group(1))
            if stack:
                stack[-1].add(node)
            else:
                roots.append(node)
            stack.append(node)
            continue
        m_cap = re.match(r"\s*Caption\s*=\s*'([^']*)'", line)
        if m_cap and stack:
            stack[-1].caption = clean_caption(m_cap.group(1))
            continue
        m_on = re.match(r"\s*On(Click|Execute)\s*=\s*(\w+)", line)
        if m_on and stack:
            stack[-1].onclick = m_on.group(2)
            continue
        m_act = re.match(r"\s*Action\s*=\s*(\w+)", line)
        if m_act and stack:
            stack[-1].action = m_act.group(1)
            continue
        # Detectar colección de subitems dentro del bloque actual
        if stack and re.match(r"\s*Items\s*=\s*<\s*", line):
            # parsear colección desde i
            items, consumed = parse_items_collection(lines, i)
            for cap, children in items:
                child = MenuNode(clean_caption(cap))
                for subcap in children:
                    child.add(MenuNode(clean_caption(subcap)))
                stack[-1].add(child)
            # saltar líneas consumidas
            # no podemos alterar el for i, pero esto es lineal; ignoramos
            continue
        if re.match(r"\s*end\b", line) and stack:
            stack.pop()
            continue

    return prune_tree(roots)


def parse_items_collection(lines: list[str], start_index: int):
    # Devuelve ([(caption, [child_captions])], consumed_lines)
    items: list[tuple[str, list[str]]] = []
    i = start_index
    # avanzar al '<'
    # contamos balance de '<' '>' y 'item'/'end'
    # estructura: Items = < item ... end item ... end >
    # No recursivo profundo; pero si encontramos Items anidados tratamos sus captions como hijos
    if not re.match(r"\s*Items\s*=\s*<\s*", lines[i]):
        return items, 0
    i += 1
    depth_angle = 1
    while i < len(lines) and depth_angle > 0:
        line = lines[i]
        if re.match(r"\s*item\b", line):
            # leer un item hasta 'end'
            cap = ""
            subs: list[str] = []
            i += 1
            while i < len(lines):
                l2 = lines[i]
                mcap = re.match(r"\s*(Caption|Text)\s*=\s*'([^']*)'", l2)
                if mcap:
                    cap = mcap.group(2)
                elif re.match(r"\s*Items\s*=\s*<\s*", l2):
                    sub_items, consumed = parse_items_collection(lines, i)
                    subs.extend([c for c in [s for s in [si for (si, _) in sub_items]] if c])
                    i += consumed
                    continue
                elif re.match(r"\s*Buttons\s*=\s*<\s*", l2):
                    # botones de OutlookBar
                    btns, consumed = parse_buttons_collection(lines, i)
                    subs.extend(btns)
                    i += consumed
                    continue
                elif re.match(r"\s*end\b", l2):
                    break
                i += 1
            items.append((cap, subs))
        elif ">" in line:
            depth_angle -= 1
        i += 1
    consumed = i - start_index
    return items, consumed


def parse_buttons_collection(lines: list[str], start_index: int):
    # Similar a Items, pero extrae Caption/Text y OnClick de botones
    entries: list[str] | list[tuple[str, str | None]] = []
    i = start_index
    if not re.match(r"\s*Buttons\s*=\s*<\s*", lines[i]):
        return [], 0
    i += 1
    depth_angle = 1
    while i < len(lines) and depth_angle > 0:
        line = lines[i]
        if re.match(r"\s*item\b", line):
            cap = ""
            onclick = None
            i += 1
            while i < len(lines):
                l2 = lines[i]
                mcap = re.match(r"\s*(Caption|Text)\s*=\s*'([^']*)'", l2)
                if mcap:
                    cap = mcap.group(2)
                mon = re.match(r"\s*On(Click|Execute)\s*=\s*(\w+)", l2)
                if mon:
                    onclick = mon.group(2)
                elif re.match(r"\s*end\b", l2):
                    break
                i += 1
            if cap:
                entries.append((cap, onclick))
        elif ">" in line:
            depth_angle -= 1
        i += 1
    return entries, (i - start_index)


def prune_tree(nodes: list[MenuNode]) -> list[MenuNode]:
    def prune(nodes: list[MenuNode]) -> list[MenuNode]:
        out: list[MenuNode] = []
        for n in nodes:
            n.children = prune(n.children)
            if n.caption or n.children:
                out.append(n)
        return out
    return prune(nodes)


def parse_jv_components(lines: list[str]) -> list[MenuNode]:
    # Procesa TJvOutlookBar, TJvLookOut y TPageControl (pestañas)
    nodes: list[MenuNode] = []
    i = 0
    n = len(lines)
    while i < n:
        line = lines[i]
        m_obj = re.match(r"\s*object\s+(\w+)\s*:\s*(TJvOutlookBar|TJvLookOut|TPageControl)\b", line)
        if not m_obj:
            i += 1
            continue
        cls = m_obj.group(2)
        # Capturar bloque balanceando 'object'/'end'
        start = i
        depth = 0
        j = i
        while j < n:
            l = lines[j]
            if re.match(r"\s*object\b", l):
                depth += 1
            if re.match(r"\s*end\b", l):
                depth -= 1
                if depth == 0:
                    break
            j += 1
        block = lines[start:j+1]
        # Parsear colecciones según clase
        if cls == 'TJvOutlookBar':
            nodes.extend(parse_jv_outlookbar_block(block))
        elif cls == 'TJvLookOut':
            nodes.extend(parse_jv_lookout_block(block))
        else:
            nodes.extend(parse_pagecontrol_block(block))
        i = j + 1
    return prune_tree(nodes)


def parse_popup_menus(lines: list[str]) -> dict[str, list[MenuNode]]:
    # Devuelve mapa: nombre del popup -> lista de nodos de primer nivel
    popups: dict[str, list[MenuNode]] = {}
    i = 0
    n = len(lines)
    while i < n:
        line = lines[i]
        m = re.match(r"\s*object\s+(\w+)\s*:\s*(TPopupMenu|TJvPopupMenu)\b", line)
        if not m:
            i += 1
            continue
        name = m.group(1)
        # Capturar bloque
        start = i
        depth = 0
        j = i
        while j < n:
            l = lines[j]
            if re.match(r"\s*object\b", l):
                depth += 1
            if re.match(r"\s*end\b", l):
                depth -= 1
                if depth == 0:
                    break
            j += 1
        block = lines[start:j+1]
        # Parsear TMenuItem dentro del bloque
        roots: list[MenuNode] = []
        stack: list[MenuNode] = []
        for bl in block[1:]:  # saltar la cabecera del popup
            m_item = re.match(r"\s*object\s+(\w+)\s*:\s*TMenuItem\b", bl)
            if m_item:
                node = MenuNode("", name=m_item.group(1))
                if stack:
                    stack[-1].add(node)
                else:
                    roots.append(node)
                stack.append(node)
                continue
            m_cap = re.match(r"\s*Caption\s*=\s*'([^']*)'", bl)
            if m_cap and stack:
                stack[-1].caption = clean_caption(m_cap.group(1))
                continue
            m_on = re.match(r"\s*On(Click|Execute)\s*=\s*(\w+)", bl)
            if m_on and stack:
                stack[-1].onclick = m_on.group(2)
                continue
            m_act = re.match(r"\s*Action\s*=\s*(\w+)", bl)
            if m_act and stack:
                stack[-1].action = m_act.group(1)
                continue
            if re.match(r"\s*end\b", bl) and stack:
                stack.pop()
                continue
        popups[name] = prune_tree(roots)
        i = j + 1
    return popups


def parse_pagecontrol_block(block_lines: list[str]) -> list[MenuNode]:
    # Extrae títulos de TTabSheet dentro del PageControl
    nodes: list[MenuNode] = []
    i = 0
    while i < len(block_lines):
        line = block_lines[i]
        m_tab = re.match(r"\s*object\s+(\w+)\s*:\s*TTabSheet\b", line)
        if m_tab:
            # buscar Caption más cercano dentro de este sub-bloque hasta su 'end'
            cap = ""
            depth = 0
            j = i
            while j < len(block_lines):
                l2 = block_lines[j]
                if re.match(r"\s*object\b", l2):
                    depth += 1
                if re.match(r"\s*(Caption|Text)\s*=\s*'([^']*)'", l2):
                    cap = re.match(r"\s*(Caption|Text)\s*=\s*'([^']*)'", l2).group(2)
                if re.match(r"\s*end\b", l2):
                    depth -= 1
                    if depth == 0:
                        break
                j += 1
            if cap:
                nodes.append(MenuNode(clean_caption(cap)))
            i = j
        i += 1
    return nodes


def parse_jv_outlookbar_block(block_lines: list[str]) -> list[MenuNode]:
    # Buscar Pages = < item ... Buttons = < item ... > end ... >
    nodes: list[MenuNode] = []
    i = 0
    while i < len(block_lines):
        line = block_lines[i]
        if re.match(r"\s*Pages\s*=\s*<\s*", line):
            pages, consumed = parse_pages_collection(block_lines, i)
            for cap, btns in pages:
                top = MenuNode(clean_caption(cap))
                for bcap, bon in btns:
                    child = MenuNode(clean_caption(bcap))
                    child.onclick = bon
                    top.add(child)
                nodes.append(top)
            i += consumed
            continue
        i += 1
    return nodes


def parse_pages_collection(lines: list[str], start_index: int):
    pages: list[tuple[str, list[tuple[str, str | None]]]] = []
    i = start_index
    if not re.match(r"\s*Pages\s*=\s*<\s*", lines[i]):
        return pages, 0
    i += 1
    depth = 1
    while i < len(lines) and depth > 0:
        line = lines[i]
        if re.match(r"\s*item\b", line):
            cap = ""
            buttons: list[tuple[str, str | None]] = []
            i += 1
            while i < len(lines):
                l2 = lines[i]
                mcap = re.match(r"\s*(Caption|Text)\s*=\s*'([^']*)'", l2)
                if mcap:
                    cap = mcap.group(2)
                elif re.match(r"\s*Buttons\s*=\s*<\s*", l2):
                    btns, consumed = parse_buttons_collection(lines, i)
                    buttons.extend(btns)  # list of (caption, onclick)
                    i += consumed
                    continue
                elif re.match(r"\s*end\b", l2):
                    break
                i += 1
            pages.append((cap, buttons))
        elif ">" in line:
            depth -= 1
        i += 1
    return pages, (i - start_index)


def parse_jv_lookout_block(block_lines: list[str]) -> list[MenuNode]:
    # Buscar Groups = < item Caption='...' Items = < item Caption='...' ... > >
    nodes: list[MenuNode] = []
    i = 0
    while i < len(block_lines):
        line = block_lines[i]
        if re.match(r"\s*Groups\s*=\s*<\s*", line):
            groups, consumed = parse_groups_collection(block_lines, i)
            for cap, items in groups:
                top = MenuNode(clean_caption(cap))
                for itcap, iton in items:
                    ch = MenuNode(clean_caption(itcap))
                    ch.onclick = iton
                    top.add(ch)
                nodes.append(top)
            i += consumed
            continue
        i += 1
    return nodes


def parse_groups_collection(lines: list[str], start_index: int):
    groups: list[tuple[str, list[tuple[str, str | None]]]] = []
    i = start_index
    if not re.match(r"\s*Groups\s*=\s*<\s*", lines[i]):
        return groups, 0
    i += 1
    depth = 1
    while i < len(lines) and depth > 0:
        line = lines[i]
        if re.match(r"\s*item\b", line):
            cap = ""
            entries: list[tuple[str, str | None]] = []
            i += 1
            while i < len(lines):
                l2 = lines[i]
                mcap = re.match(r"\s*(Caption|Text)\s*=\s*'([^']*)'", l2)
                if mcap:
                    cap = mcap.group(2)
                elif re.match(r"\s*Items\s*=\s*<\s*", l2):
                    its, consumed = parse_buttons_collection(lines, i)
                    entries.extend(its)  # list of (caption, onclick)
                    i += consumed
                    continue
                elif re.match(r"\s*end\b", l2):
                    break
                i += 1
            groups.append((cap, entries))
        elif ">" in line:
            depth -= 1
        i += 1
    return groups, (i - start_index)


def parse_actions(lines: list[str]):
    # Extrae acciones de TActionList: nombre -> {caption, onexecute}
    actions: dict[str, dict] = {}
    i = 0
    n = len(lines)
    while i < n:
        line = lines[i]
        m = re.match(r"\s*object\s+(\w+)\s*:\s*TActionList\b", line)
        if not m:
            i += 1
            continue
        # Capturar bloque del ActionList balanceando 'object'/'end'
        start = i
        depth = 0
        j = i
        while j < n:
            l = lines[j]
            if re.match(r"\s*object\b", l):
                depth += 1
            if re.match(r"\s*end\b", l):
                depth -= 1
                if depth == 0:
                    break
            j += 1
        block = lines[start:j+1]
        # Buscar acciones dentro del bloque
        k = 0
        while k < len(block):
            l2 = block[k]
            ma = re.match(r"\s*object\s+(\w+)\s*:\s*TAction\b", l2)
            if ma:
                aname = ma.group(1)
                acap = None
                aon = None
                k += 1
                while k < len(block):
                    l3 = block[k]
                    mcap = re.match(r"\s*Caption\s*=\s*'([^']*)'", l3)
                    if mcap:
                        acap = mcap.group(1)
                    mon = re.match(r"\s*On(Execute|Click)\s*=\s*(\w+)", l3)
                    if mon:
                        aon = mon.group(2)
                    if re.match(r"\s*end\b", l3):
                        break
                    k += 1
                actions[aname] = {"caption": acap, "on": aon}
            k += 1
        i = j + 1
    return actions


def scan_system(path: str) -> list[MenuNode]:
    topnodes: list[MenuNode] = []
    base = Path(path)
    if not base.exists():
        return []
    # Prefer obvious menu files first
    candidates: list[Path] = []
    for pat in ("**/Menu.dfm", "**/*Menu*.dfm", "**/*Principal*.dfm", "**/*Main*.dfm", "**/*.dfm"):
        candidates = list(base.glob(pat))
        if candidates:
            break
    seen = set()
    for dfm in candidates:
        # skip duplicates
        if dfm in seen:
            continue
        seen.add(dfm)
        # parse acciones del DFM actual
        try:
            raw = dfm.read_text(encoding="utf-8")
        except UnicodeDecodeError:
            raw = dfm.read_text(encoding="latin-1", errors="ignore")
        lines = raw.splitlines()
        actions = parse_actions(lines)
        popups = parse_popup_menus(lines)
        nodes = parse_dfm_menu(dfm)
        if nodes:
            # anotar acciones
            annotate_nodes_with_actions(nodes, actions)
            # intentar resolver métodos en archivos .pas
            pas_files = list(base.glob("**/*.pas"))
            annotate_nodes_with_forms(nodes, pas_files, popups)
        # choose first non-empty menu
        if nodes:
            return nodes
    return topnodes


def annotate_nodes_with_actions(nodes: list[MenuNode], actions: dict):
    def walk(n: MenuNode):
        if n.action and n.action in actions:
            a = actions[n.action]
            if not n.caption and a.get("caption"):
                n.caption = clean_caption(a["caption"])
            if a.get("on") and not n.onclick:
                n.onclick = a["on"]
        for c in n.children:
            walk(c)
    for node in nodes:
        walk(node)


def annotate_nodes_with_forms(nodes: list[MenuNode], pas_files: list[Path], popups: dict[str, list[MenuNode]]):
    # Construye un índice rápido de archivos y contenido
    cache: dict[Path, str] = {}

    def file_text(p: Path) -> str:
        if p not in cache:
            try:
                cache[p] = p.read_text(encoding="utf-8")
            except UnicodeDecodeError:
                cache[p] = p.read_text(encoding="latin-1", errors="ignore")
            except Exception:
                cache[p] = ""
        return cache[p]

    def search_in_files(patterns: list[re.Pattern]):
        for pf in pas_files:
            txt = file_text(pf)
            for pat in patterns:
                for m in pat.finditer(txt):
                    yield pf, m

    def resolve_from_method(method: str):
        # Busca el procedimiento y dentro el primer patrón de apertura de forma
        proc_header = re.compile(rf"^\s*procedure\s+\w*\.?{re.escape(method)}\s*\([^;]*\);\s*begin(.*?)^\s*end\s*;", re.M|re.S)
        create_form_pat = re.compile(r"Application\.CreateForm\(\s*T(\w+)\s*,\s*(\w+)\s*\)")
        new_pat = re.compile(r"(\w+)\s*:=\s*T(\w+)\.Create\s*\(")
        showmodal_pat = re.compile(r"(\w+)\.(ShowModal|Show)\s*\(\s*\)", re.I)
        popup_pat = re.compile(r"(\w+)\.Popup\s*\(")
        # scan files
        for pf in pas_files:
            txt = file_text(pf)
            mh = proc_header.search(txt)
            if not mh:
                continue
            body = mh.group(1)
            # Popup primero: puede ser solo menú contextual
            mp = popup_pat.search(body)
            popup_name = mp.group(1) if mp else None
            # Try Application.CreateForm
            m = create_form_pat.search(body)
            if m:
                cls, var = m.group(1), m.group(2)
                mode = None
                ms = showmodal_pat.search(body)
                if ms and ms.group(1) == var:
                    mode = ms.group(2)
                return {"cls": cls, "var": var, "mode": mode, "popup": popup_name}
            # Try direct Create
            m2 = new_pat.search(body)
            if m2:
                var, cls = m2.group(1), m2.group(2)
                mode = None
                ms = showmodal_pat.search(body)
                if ms and ms.group(1) == var:
                    mode = ms.group(2)
                return {"cls": cls, "var": var, "mode": mode, "popup": popup_name}
            # Try any .ShowModal or .Show on a known form variable name pattern
            ms = showmodal_pat.search(body)
            if ms:
                return {"cls": None, "var": ms.group(1), "mode": ms.group(2), "popup": popup_name}
        return None

    def walk(n: MenuNode):
        handler = n.onclick
        if handler:
            res = resolve_from_method(handler)
            if res:
                cls, var, mode, popup_name = res.get("cls"), res.get("var"), res.get("mode"), res.get("popup")
                if cls:
                    n.target_form_class = f"T{cls}" if cls and not cls.startswith('T') else cls
                if var:
                    n.target_form_var = var
                if mode:
                    n.open_mode = mode
                if popup_name and popup_name in popups and not n.children:
                    # Adjuntar los elementos del popup como hijos
                    for ch in popups[popup_name]:
                        n.add(ch)
        for c in n.children:
            walk(c)

    for node in nodes:
        walk(node)


def render_markdown(system: str, nodes: list[MenuNode]) -> str:
    lines = [f"#{system}"]

    def emit(n: MenuNode, depth: int):
        prefix = "-" * (depth + 1)
        caption = n.caption or "(sin título)"
        extra = []
        if n.target_form_class or n.target_form_var:
            tgt = n.target_form_class or n.target_form_var
            if tgt:
                if n.open_mode:
                    extra.append(f"-> {tgt} ({n.open_mode})")
                else:
                    extra.append(f"-> {tgt}")
        elif n.onclick or n.action:
            # Si no se pudo resolver forma, al menos mostrar el handler o acción
            ref = n.onclick or n.action
            if ref:
                extra.append(f"[{ref}]")
        tail = (" " + " ".join(extra)) if extra else ""
        lines.append(f"{prefix} {caption}{tail}")
        for c in n.children:
            emit(c, depth + 1)

    for node in nodes:
        emit(node, 0)
    lines.append("")
    return "\n".join(lines)


def main():
    systems = read_instrucciones()
    sections: list[str] = []
    for sysname, ruta in systems:
        nodes = scan_system(ruta)
        if not nodes:
            # still output header with note
            sections.append(f"#{sysname}\n- (No se detectó menú en DFM)\n")
        else:
            sections.append(render_markdown(sysname, nodes))

    OUTPUT_PATH.parent.mkdir(parents=True, exist_ok=True)
    OUTPUT_PATH.write_text("\n".join(sections), encoding="utf-8")


if __name__ == "__main__":
    main()
