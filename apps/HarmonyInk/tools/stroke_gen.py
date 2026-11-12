"""笔画路径生成辅助库（归一化 0-100 坐标系，y 轴向下）。

每个 helper 返回 (笔画类型, 控制折线点列表)，
最终由 gen_chars.py 等距重采样后写入 chars.json。
"""


def _quad(p0, p1, p2, n=14):
    pts = []
    for i in range(n + 1):
        t = i / n
        x = (1 - t) * (1 - t) * p0[0] + 2 * (1 - t) * t * p1[0] + t * t * p2[0]
        y = (1 - t) * (1 - t) * p0[1] + 2 * (1 - t) * t * p1[1] + t * t * p2[1]
        pts.append((x, y))
    return pts


def _line(p0, p1, n=6):
    return [(p0[0] + (p1[0] - p0[0]) * i / n,
             p0[1] + (p1[1] - p0[1]) * i / n) for i in range(n + 1)]


def _join(*segments):
    out = []
    for seg in segments:
        for p in seg:
            if not out or abs(out[-1][0] - p[0]) > 1e-4 or abs(out[-1][1] - p[1]) > 1e-4:
                out.append(p)
    return out


def H(y, x1=15, x2=85):
    """横：略向上拱"""
    return ("横", _quad((x1, y), ((x1 + x2) / 2, y - 2.2), (x2, y - 1.0), 16))


def V(x, y1=16, y2=84):
    """竖：略向右弓"""
    return ("竖", _quad((x, y1), (x + 1.2, (y1 + y2) / 2), (x, y2), 16))


def P(x1=50, y1=20, x2=26, y2=80):
    """撇：向左下弧出"""
    ctrl = (x1 - (x1 - x2) * 0.18, y1 + (y2 - y1) * 0.42)
    return ("撇", _quad((x1, y1), ctrl, (x2, y2), 18))


def N(x1=50, y1=26, x2=78, y2=80):
    """捺：向右下铺开"""
    ctrl = (x1 + (x2 - x1) * 0.42, y1 + (y2 - y1) * 0.12)
    return ("捺", _quad((x1, y1), ctrl, (x2, y2), 18))


def D(x=52, y=26, dx=6, dy=8):
    """点：短促的右下笔触"""
    ctrl = (x + dx * 0.55, y + dy * 0.15)
    return ("点", _quad((x, y), ctrl, (x + dx, y + dy), 10))


def T(x1=28, y1=70, x2=60, y2=54):
    """提：左下至右上"""
    return ("提", _quad((x1, y1), ((x1 + x2) / 2, (y1 + y2) / 2 - 1), (x2, y2), 10))


def HZ(x1=28, y1=22, x2=72, y2=78):
    """横折"""
    return ("横折", _join(
        _quad((x1, y1), ((x1 + x2) / 2, y1 - 1.2), (x2, y1), 12),
        _quad((x2, y1), (x2 + 0.6, (y1 + y2) / 2), (x2, y2), 14)))


def HZG(x1=36, y1=18, x2=72, y2=80):
    """横折钩"""
    body = HZ(x1, y1, x2, y2)
    hook = _quad((x2, y2), (x2 - 3.2, y2 - 1.6), (x2 - 6.5, y2 - 5.5), 8)
    return ("横折钩", _join(body[1], hook))


def HZWG(x1=32, y1=28, x2=76, y2=70):
    """横折弯钩"""
    top = _quad((x1, y1), ((x1 + x2) / 2, y1 - 1.2), (x2, y1), 12)
    drop = _quad((x2, y1), (x2, y2), (x2 - 7, y2), 14)
    hook = _quad((x2 - 7, y2), (x2 - 8, y2 - 3), (x2 - 6, y2 - 8), 8)
    return ("横折弯钩", _join(top, drop, hook))


def SZ(x=28, y1=34, y2=78, x2=74):
    """竖折"""
    return ("竖折", _join(
        _quad((x, y1), (x + 1, (y1 + y2) / 2), (x, y2), 14),
        _quad((x, y2), ((x + x2) / 2, y2 + 0.8), (x2, y2), 12)))


def SZZG(x=44, y1=26, y2=52, x2=70, y3=76):
    """竖折折钩"""
    seg1 = _quad((x, y1), (x + 0.8, (y1 + y2) / 2), (x, y2), 10)
    seg2 = _quad((x, y2), ((x + x2) / 2, y2 - 0.8), (x2, y2), 10)
    seg3 = _quad((x2, y2), (x2 + 0.8, (y2 + y3) / 2), (x2, y3), 10)
    hook = _quad((x2, y3), (x2 - 3, y3 - 1.4), (x2 - 6, y3 - 5), 6)
    return ("竖折折钩", _join(seg1, seg2, seg3, hook))


def SG(x=50, y1=18, y2=80):
    """竖钩"""
    body = _quad((x, y1), (x + 1.2, (y1 + y2) / 2), (x, y2), 18)
    hook = _quad((x, y2), (x - 3, y2 - 1.4), (x - 6, y2 - 4.6), 8)
    return ("竖钩", _join(body, hook))


def SWG(x=46, y1=22, y2=78, x2=76):
    """竖弯钩"""
    drop = _quad((x, y1), (x + 1.0, (y1 + y2) / 2), (x, y2 - 6), 16)
    bend = _quad((x, y2 - 6), (x + 4, y2), (x2, y2), 14)
    hook = _quad((x2, y2), (x2 + 2.4, y2 - 3), (x2 + 1.5, y2 - 8), 8)
    return ("竖弯钩", _join(drop, bend, hook))


def WG(x=50, y1=34, y2=80):
    """弯钩"""
    body = _quad((x, y1), (x + 8, y1 + (y2 - y1) * 0.45), (x, y2), 18)
    hook = _quad((x, y2), (x - 3, y2 - 1.4), (x - 6, y2 - 4.6), 8)
    return ("弯钩", _join(body, hook))


def WGOU(x1=38, y=52, x2=70):
    """卧钩：先下行再平铺，末端向左上钩出"""
    body = _quad((x1, y), (x1 + 10, y + 18), (x2, y + 4), 18)
    hook = _quad((x2, y + 4), (x2 - 2, y), (x2 - 5, y - 6), 8)
    return ("卧钩", _join(body, hook))


def XG(x1=56, y1=24, x2=74, y2=82):
    """斜钩"""
    ctrl = ((x1 + x2) / 2 + 5, (y1 + y2) / 2)
    body = _quad((x1, y1), ctrl, (x2, y2), 18)
    hook = _quad((x2, y2), (x2 + 1, y2 - 4), (x2 + 4, y2 - 8), 8)
    return ("斜钩", _join(body, hook))


def HP(x1=34, y1=30, x2=58, y2=30, x3=24, y3=54):
    """横撇"""
    bar = _quad((x1, y1), ((x1 + x2) / 2, y1 - 1), (x2, y2), 10)
    tail = _quad((x2, y2), (x2 - 6, y2 + 5), (x3, y3), 14)
    return ("横撇", _join(bar, tail))


def PD(x1=44, y1=30, x2=30, y2=58, x3=62, y3=58):
    """撇折"""
    tail = _quad((x1, y1), (x1 - 3, y1 + 8), (x2, y2), 12)
    bar = _quad((x2, y2), ((x2 + x3) / 2, y3 - 0.8), (x3, y3), 10)
    return ("撇折", _join(tail, bar))


def PDI(x1=48, y1=18, x2=32, y2=50, x3=54, y3=62):
    """撇点"""
    pie = _quad((x1, y1), (x1 - 4, y1 + 10), (x2, y2), 12)
    dot = _quad((x2, y2), (x2 + 8, y2 + 2), (x3, y3), 10)
    return ("撇点", _join(pie, dot))


def ST(x=40, y1=28, y2=70, tx=58, ty=58):
    """竖提"""
    body = _quad((x, y1), (x + 0.8, (y1 + y2) / 2), (x, y2), 14)
    ti = _quad((x, y2), ((x + tx) / 2, (y2 + ty) / 2 - 1), (tx, ty), 10)
    return ("竖提", _join(body, ti))


def HZT(x1=34, y1=28, x2=56, y2=48):
    """横折提"""
    bar = _quad((x1, y1), ((x1 + x2) / 2, y1 - 1), (x2, y1), 10)
    fold = _quad((x2, y1), (x2, y1 + (y2 - y1) * 0.6), (x2 - 2, y2), 8)
    ti = _quad((x2 - 2, y2), (x2 - 12, y2 - 2), (x2 - 20, y2 - 8), 10)
    return ("横折提", _join(bar, fold, ti))


def HG(x1=28, y1=30, x2=72, y2=30):
    """横钩"""
    bar = _quad((x1, y1), ((x1 + x2) / 2, y1 - 1.5), (x2, y2), 14)
    hook = _quad((x2, y2), (x2 - 2.4, y2 + 2.6), (x2 - 6, y2 + 5.5), 8)
    return ("横钩", _join(bar, hook))
