import 'package:flutter/material.dart';

void main() => runApp(const MaterialApp(home: Scaffold(body: MyTreeView())));

// Класс для хранения иерархических данных
class MyNode {
  String title;
  List<MyNode> children;

  MyNode({required this.title, this.children = const []});
}

class MyTreeView extends StatefulWidget {
  const MyTreeView({super.key});

  @override
  State<MyTreeView> createState() => _MyTreeViewState();
}

class _MyTreeViewState extends State<MyTreeView> {
  final List<MyNode> roots = [
    MyNode(
      title: 'Root 1',
      children: [
        MyNode(
          title: 'Node 1.1',
          children: [
            MyNode(title: 'Node 1.1.1'),
            MyNode(title: 'Node 1.1.2'),
          ],
        ),
        MyNode(title: 'Node 1.2'),
      ],
    ),
  ];

  MyNode? selectedNode;

  void _addNode(String title) {
    if (selectedNode != null) {
      setState(() {
        selectedNode!.children.add(MyNode(title: title));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AddNodeForm(
          onAddNode: _addNode,
          onNodeSelected: (node) {
            setState(() {
              selectedNode = node; // Устанавливаем выбранный узел
            });
          },
          nodes: roots,
        ),
        Expanded(
          child: ListView(
            children: _buildTree(roots),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildTree(List<MyNode> nodes) {
    return nodes.map((node) {
      return ExpansionTile(
        title: Text(node.title),
        children: _buildTree(node.children),
      );
    }).toList();
  }
}

// Форма для добавления нового узла
class AddNodeForm extends StatefulWidget {
  final Function(String) onAddNode;
  final Function(MyNode) onNodeSelected;
  final List<MyNode> nodes;

  const AddNodeForm({
    Key? key,
    required this.onAddNode,
    required this.onNodeSelected,
    required this.nodes,
  }) : super(key: key);

  @override
  _AddNodeFormState createState() => _AddNodeFormState();
}

class _AddNodeFormState extends State<AddNodeForm> {
  final TextEditingController _controller = TextEditingController();
  MyNode? selectedNode;

  void _submit() {
    final title = _controller.text;
    if (title.isNotEmpty && selectedNode != null) {
      widget.onAddNode(title);
      _controller.clear();
      setState(() {
        selectedNode = null; // Сбросить выбранный узел после добавления
      });
    }
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
          hint: const Text('Выберите узел'),
          value: selectedNode,
          onChanged: (MyNode? newValue) {
            setState(() {
              selectedNode = newValue;
              if (newValue != null) {
                widget.onNodeSelected(newValue);
              }
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
        IconButton(
          icon: const Icon(Icons.add),
          onPressed: _submit,
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
