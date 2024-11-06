import 'package:flutter/material.dart';
import 'package:flutter_fancy_tree_view/flutter_fancy_tree_view.dart';

void main() => runApp(const MaterialApp(home: Scaffold(body: MyTreeView())));

class MyNode {
  const MyNode({
    required this.title,
    this.children = const <MyNode>[],
  });

  final String title;
  final List<MyNode> children;
}

class MyTreeView extends StatefulWidget {
  const MyTreeView({super.key});

  @override
  State<MyTreeView> createState() => _MyTreeViewState();
}

class _MyTreeViewState extends State<MyTreeView> {
  static const List<MyNode> roots = <MyNode>[
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

  void _showAddNodeDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AddNodeDialog(
          onAddNode: (String title, MyNode parentNode) {
            setState(() {
              parentNode.children.add(MyNode(title: title));
            });
            Navigator.of(context).pop();
          },
          nodes: roots,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: _showAddNodeDialog,
          child: const Text('Добавить узел'),
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

class AddNodeDialog extends StatefulWidget {
  final Function(String title, MyNode parentNode) onAddNode;
  final List<MyNode> nodes;

  const AddNodeDialog({
    super.key,
    required this.onAddNode,
    required this.nodes,
  });

  @override
  _AddNodeDialogState createState() => _AddNodeDialogState();
}

class _AddNodeDialogState extends State<AddNodeDialog> {
  final TextEditingController _controller = TextEditingController();
  MyNode? selectedNode;

  void _submit() {
    final title = _controller.text;
    if (title.isNotEmpty && selectedNode != null) {
      widget.onAddNode(title, selectedNode!);
      _controller.clear();
      Navigator.of(context).pop(); // Закрыть модальное окно
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Добавить новый узел'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _controller,
            decoration: const InputDecoration(labelText: 'Название узла'),
          ),
          DropdownButton<MyNode>(
            hint: const Text('Выберите родительский узел'),
            value: selectedNode,
            onChanged: (MyNode? newValue) {
              setState(() {
                selectedNode = newValue;
              });
            },
            items: _getAllNodes(widget.nodes)
                .map<DropdownMenuItem<MyNode>>((MyNode node) {
              return DropdownMenuItem<MyNode>(
                value: node,
                child: Text(node.title),
              );
            }).toList(),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(), // Закрыть модальное окно
          child: const Text('Отмена'),
        ),
        ElevatedButton(
          onPressed: _submit,
          child: const Text('Добавить'),
        ),
      ],
    );
  }

  List<MyNode> _getAllNodes(List<MyNode> nodes) {
    List<MyNode> allNodes = [];
    for (var node in nodes) {
      allNodes.add(node);
      allNodes.addAll(_getAllNodes(node.children));
    }
    return allNodes;
  }
}

