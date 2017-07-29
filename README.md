Joseph
======

Joseph is a lightweight auto-layout constraints description framework for Swift.

Every constraint can be expressed by a single code line, with the use of custom operator.

#### Notice

Simply add `Joseph.swift` file into your project to start using it.

This project is compatible with Xcode 8.x and iOS 8+.

#### Examples

Set `view2` frame with margins inset and extra 20pt margin on top and bottom:

```
view2.edges = view1.margins + UIOffset(horizontal: 0, vertical: 20)

```

Set `view2` under `view1` with 10pt, and a priority of 751:

```
view2.top = view1.bottom + 10 ~ 751

```

Align `view2` left on `view1` left-margin, multiply by 1.5:

```
view2.left = view1.leftMargin * 1.5

```

Set `view2` width between 220pt and 280pt:

```
view2.width.in(220...280)

// Same that:
220 <= view1.width; view1.width <= 280

```

Set `view2` twice taller with priority of 251:

```
view2.height = view1.height × 2 ~ 251

```


Set `view3` centred with `view2`:

```
view3.middle = view2.middle

```

Set `view3` wider or same width:

```
view3.width >= view2.width

```

Set `view2` taller or same height:

```
view3.height <= view2.height

```

Set `view3` 2/3 ratio (3 * width = 2 * height):

```
view3.ratio = 2∶3

```

Set hugging resistance for x-axis to 249:

```
view3.x <~> 249

```

Set shrink resistance for y-axis to 751:

```
view3.y >~< 751

```

#### About

The code source is in public domain.

[Lisacintosh](https://www.lisacintosh.com/), 2017