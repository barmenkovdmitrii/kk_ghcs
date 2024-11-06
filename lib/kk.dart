import 'package:flutter/material.dart';
import 'package:flutter_fancy_tree_view/flutter_fancy_tree_view.dart';

void main() => runApp(const MaterialApp(home: Scaffold(body: MyTreeView())));

class MyNode {
  const MyNode({
    required this.title,
    List<MyNode>? children,
  }) : children = children ?? const [];

  final String title;
  final List<MyNode> children; // Делаем это поле final
}

class MyTreeView extends StatefulWidget {
  const MyTreeView({super.key});

  @override
  State<MyTreeView> createState() => _MyTreeViewState();
}

class _MyTreeViewState extends State<MyTreeView> {
  static List<MyNode> roots = <MyNode>[
    MyNode(
      title: 'Root 1',
      children: <MyNode>[
        MyNode(
          title: 'Node 1.1',
          children: <MyNode>[
            MyNode(title: 'Node 1.1.1'),
            MyNode(title: 'Node 1.1.2'),
          ],
        ),
        MyNode(title: 'Node 1.2'),
      ],
    ),
    MyNode(
      title: 'Root 2',
      children: <MyNode>[
        MyNode(
          title: 'Node 2.1',
          children: <MyNode>[
            MyNode(title: 'Node 2.1.1'),
          ],
        ),
        MyNode(title: 'Node 2.2')
      ],
    ),
  ];

  late final TreeController<MyNode> treeController;

  @override
  void initState() {
    super.initState();
    treeController = TreeController<MyNode>(
      roots: roots,
      childrenProvider: (MyNode node) => node.children,
    );
  }

  @override
  void dispose() {
    treeController.dispose();
    super.dispose();
  }

  void _addNode(String title, MyNode parent) {
    // Добавляем новый узел к выбранному родителю
    setState(() {
      parent.children.add(MyNode(title: title));
      treeController.rebuild();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: AddNodeForm(
            onSubmit: _addNode,
            roots: roots,
          ),
        ),
        Expanded(
          child: TreeView<MyNode>(
            treeController: treeController,
            nodeBuilder: (BuildContext context, TreeEntry<MyNode> entry) {
              return MyTreeTile(
                key: ValueKey(entry.node),
                entry: entry,
                onTap: () => treeController.toggleExpansion(entry.node),
              );
            },
          ),
        ),
      ],
    );
  }
}

class AddNodeForm extends StatefulWidget {
  final Function(String, MyNode) onSubmit;
  final List<MyNode> roots;

  const AddNodeForm({Key? key, required this.onSubmit, required this.roots}) : super(key: key);

  @override
  _AddNodeFormState createState() => _AddNodeFormState();
}

class _AddNodeFormState extends State<AddNodeForm> {
  final TextEditingController _controller = TextEditingController();
  MyNode? _selectedParent;

  List<MyNode> _getAllNodes(List<MyNode> nodes) {
    List<MyNode> allNodes = [];
    for (var node in nodes) {
      allNodes.add(node);
      allNodes.addAll(_getAllNodes(node.children));
    }
    return allNodes;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _controller,
            decoration: const InputDecoration(labelText: 'Node Title'),
          ),
        ),
        DropdownButton<MyNode>(
          hint: const Text('Select Parent'),
          value: _selectedParent,
          onChanged: (MyNode? newValue) {
            setState(() {
              _selectedParent = newValue;
            });
          },
          items: _getAllNodes(widget.roots).map<DropdownMenuItem<MyNode>>((MyNode node) {
            return DropdownMenuItem<MyNode>(
              value: node,
              child: Text(node.title),
            );
          }).toList(),
        ),
        IconButton(
          icon: const Icon(Icons.add),
          onPressed: () {
            if (_selectedParent != null && _controller.text.isNotEmpty) {
              widget.onSubmit(_controller.text, _selectedParent!);
              _controller.clear();
              setState(() {
                _selectedParent = null; // Сбрасываем выбор после добавления
              });
            }
          },
        ),
      ],
    );
  }
}

class MyTreeTile extends StatelessWidget {
  const MyTreeTile({
    super.key,
    required this.entry,
    required this.onTap,
  });

  final TreeEntry<MyNode> entry;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: TreeIndentation(
        entry: entry,
        guide: const IndentGuide.connectingLines(indent: 48),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(4, 8, 8, 8),
          child: Row(
            children: [
              FolderButton(
                isOpen: entry.hasChildren ? entry.isExpanded : null,
                onPressed: entry.hasChildren ? onTap : null,
              ),
              Text(entry.node.title),
            ],
          ),
        ),
      ),
    );
  }
}

