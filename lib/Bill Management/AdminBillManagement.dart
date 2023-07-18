import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AdminBillManagement extends StatefulWidget {
  const AdminBillManagement({Key? key}) : super(key: key);

  @override
  _AdminBillManagementState createState() => _AdminBillManagementState();
}

class _AdminBillManagementState extends State<AdminBillManagement> {
  final CollectionReference _collectionRef =
      FirebaseFirestore.instance.collection('Districts');

  Stream<QuerySnapshot>? _districtsStream;
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  Future<void> _createData(String title) async {
    try {
      await _collectionRef.add({'Title': title});

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Data created successfully!'),
        ),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to create data.'),
        ),
      );
    }
  }

  Future<void> _updateData(String districtDocId, String newTitle) async {
    try {
      await _collectionRef.doc(districtDocId).update({'Title': newTitle});

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Data updated successfully!'),
        ),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to update data.'),
        ),
      );
    }
  }

  Future<void> _deleteData(String districtDocId) async {
    try {
      await _collectionRef.doc(districtDocId).delete();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Data deleted successfully!'),
        ),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to delete data.'),
        ),
      );
    }
  }

  void _performSearch(String query) {
    setState(() {
      _isSearching = query.isNotEmpty;
      _districtsStream = _collectionRef
          .where('Title', isGreaterThanOrEqualTo: query)
          .snapshots();
    });
  }

  void _clearSearch() {
    setState(() {
      _searchController.clear();
      _isSearching = false;
      _districtsStream = _collectionRef.orderBy('Title').snapshots();
    });
  }

  @override
  void initState() {
    super.initState();
    _districtsStream = _collectionRef.orderBy('Title').snapshots();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                onChanged: _performSearch,
                decoration: const InputDecoration(
                  hintText: 'Search...',
                  hintStyle: TextStyle(color: Colors.white),
                ),
                style: const TextStyle(color: Colors.white),
              )
            : const Text('Districts'),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) {
                  _clearSearch();
                }
              });
            },
            icon: Icon(
              _isSearching ? Icons.close : Icons.search,
            ),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _districtsStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: Text('Something went wrong'),
            );
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          if (snapshot.hasData) {
            final districtDocs = snapshot.data!.docs;
            if (districtDocs.isEmpty) {
              return const Center(
                child: Text('No documents found'),
              );
            }
            return ListView.builder(
              itemCount: districtDocs.length,
              itemBuilder: (context, index) {
                final districtDoc = districtDocs[index];
                Map<String, dynamic> data =
                    districtDoc.data() as Map<String, dynamic>;
                return Card(
                  child: ListTile(
                    title: Text(
                      data['Title'],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) => UpdateData(
                                initialTitle: data['Title'],
                                onUpdate: (newTitle) {
                                  _updateData(districtDoc.id, newTitle);
                                },
                              ),
                            );
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Delete Data'),
                                content: const Text(
                                    'Are you sure you want to delete this data?'),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(),
                                    child: const Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      _deleteData(districtDoc.id);
                                      Navigator.of(context).pop();
                                    },
                                    child: const Text('Delete'),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ResidentialAreaPage(
                            districtDocId: districtDoc.id,
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            );
          }
          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => CreateData(
              onCreate: _createData,
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class ResidentialAreaPage extends StatefulWidget {
  final String districtDocId;

  const ResidentialAreaPage({
    Key? key,
    required this.districtDocId,
  }) : super(key: key);

  @override
  _ResidentialAreaPageState createState() => _ResidentialAreaPageState();
}

class _ResidentialAreaPageState extends State<ResidentialAreaPage> {
  Stream<QuerySnapshot>? _residentDocsStream;
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  Future<void> _createData(String title) async {
    try {
      await FirebaseFirestore.instance
          .collection('Districts')
          .doc(widget.districtDocId)
          .collection('Residential Area')
          .add({'Title': title});

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Data created successfully!'),
        ),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to create data.'),
        ),
      );
    }
  }

  Future<void> _updateData(String residentDocId, String newTitle) async {
    try {
      await FirebaseFirestore.instance
          .collection('Districts')
          .doc(widget.districtDocId)
          .collection('Residential Area')
          .doc(residentDocId)
          .update({'Title': newTitle});

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Data updated successfully!'),
        ),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to update data.'),
        ),
      );
    }
  }

  Future<void> _deleteData(String residentDocId) async {
    try {
      await FirebaseFirestore.instance
          .collection('Districts')
          .doc(widget.districtDocId)
          .collection('Residential Area')
          .doc(residentDocId)
          .delete();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Data deleted successfully!'),
        ),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to delete data.'),
        ),
      );
    }
  }

  void _performSearch(String query) {
    setState(() {
      _residentDocsStream = FirebaseFirestore.instance
          .collection('Districts')
          .doc(widget.districtDocId)
          .collection('Residential Area')
          .where('Title', isGreaterThanOrEqualTo: query)
          .snapshots();
    });
  }

  void _clearSearch() {
    setState(() {
      _searchController.clear();
      _isSearching = false;
      _residentDocsStream = FirebaseFirestore.instance
          .collection('Districts')
          .doc(widget.districtDocId)
          .collection('Residential Area')
          .orderBy('Title')
          .snapshots();
    });
  }

  @override
  void initState() {
    super.initState();
    _residentDocsStream = FirebaseFirestore.instance
        .collection('Districts')
        .doc(widget.districtDocId)
        .collection('Residential Area')
        .orderBy('Title')
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                onChanged: _performSearch,
                decoration: const InputDecoration(
                  hintText: 'Search...',
                  hintStyle: TextStyle(color: Colors.white),
                ),
                style: const TextStyle(color: Colors.white),
              )
            : const Text('Residential Area'),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) {
                  _clearSearch();
                }
              });
            },
            icon: Icon(
              _isSearching ? Icons.close : Icons.search,
            ),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _residentDocsStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: Text('Something went wrong'),
            );
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          if (snapshot.hasData) {
            final residentDocs = snapshot.data!.docs;
            if (residentDocs.isEmpty) {
              return const Center(
                child: Text('No documents found'),
              );
            }
            return ListView.builder(
              itemCount: residentDocs.length,
              itemBuilder: (context, index) {
                final residentDoc = residentDocs[index];
                Map<String, dynamic> data =
                    residentDoc.data() as Map<String, dynamic>;
                return Card(
                  child: ListTile(
                    title: Text(
                      data['Title'],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) => UpdateData(
                                initialTitle: data['Title'],
                                onUpdate: (newTitle) {
                                  _updateData(residentDoc.id, newTitle);
                                },
                              ),
                            );
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Delete Data'),
                                content: const Text(
                                    'Are you sure you want to delete this data?'),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(),
                                    child: const Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      _deleteData(residentDoc.id);
                                      Navigator.of(context).pop();
                                    },
                                    child: const Text('Delete'),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => StreetPage(
                            districtDocId: widget.districtDocId,
                            residentDocId: residentDoc.id,
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            );
          }
          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => CreateData(
              onCreate: _createData,
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class StreetPage extends StatefulWidget {
  final String districtDocId;
  final String residentDocId;

  const StreetPage({
    Key? key,
    required this.districtDocId,
    required this.residentDocId,
  }) : super(key: key);

  @override
  _StreetPageState createState() => _StreetPageState();
}

class _StreetPageState extends State<StreetPage> {
  Stream<QuerySnapshot>? _streetDocsStream;
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  Future<void> _createData(String title) async {
    try {
      await FirebaseFirestore.instance
          .collection('Districts')
          .doc(widget.districtDocId)
          .collection('Residential Area')
          .doc(widget.residentDocId)
          .collection('Street')
          .add({'Title': title});

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Data created successfully!'),
        ),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to create data.'),
        ),
      );
    }
  }

  Future<void> _updateData(String streetDocId, String newTitle) async {
    try {
      await FirebaseFirestore.instance
          .collection('Districts')
          .doc(widget.districtDocId)
          .collection('Residential Area')
          .doc(widget.residentDocId)
          .collection('Street')
          .doc(streetDocId)
          .update({'Title': newTitle});

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Data updated successfully!'),
        ),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to update data.'),
        ),
      );
    }
  }

  Future<void> _deleteData(String streetDocId) async {
    try {
      await FirebaseFirestore.instance
          .collection('Districts')
          .doc(widget.districtDocId)
          .collection('Residential Area')
          .doc(widget.residentDocId)
          .collection('Street')
          .doc(streetDocId)
          .delete();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Data deleted successfully!'),
        ),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to delete data.'),
        ),
      );
    }
  }

  void _performSearch(String query) {
    setState(() {
      _streetDocsStream = FirebaseFirestore.instance
          .collection('Districts')
          .doc(widget.districtDocId)
          .collection('Residential Area')
          .doc(widget.residentDocId)
          .collection('Street')
          .where('Title', isGreaterThanOrEqualTo: query)
          .snapshots();
    });
  }

  void _clearSearch() {
    setState(() {
      _searchController.clear();
      _isSearching = false;
      _streetDocsStream = FirebaseFirestore.instance
          .collection('Districts')
          .doc(widget.districtDocId)
          .collection('Residential Area')
          .doc(widget.residentDocId)
          .collection('Street')
          .orderBy('Title', descending: false)
          .snapshots();
    });
  }

  @override
  void initState() {
    super.initState();
    _streetDocsStream = FirebaseFirestore.instance
        .collection('Districts')
        .doc(widget.districtDocId)
        .collection('Residential Area')
        .doc(widget.residentDocId)
        .collection('Street')
        .orderBy('Title', descending: false)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                onChanged: _performSearch,
                decoration: const InputDecoration(
                  hintText: 'Search...',
                  hintStyle: TextStyle(color: Colors.white),
                ),
                style: const TextStyle(color: Colors.white),
              )
            : const Text('Street'),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) {
                  _clearSearch();
                }
              });
            },
            icon: Icon(
              _isSearching ? Icons.close : Icons.search,
            ),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _streetDocsStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: Text('Something went wrong'),
            );
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          if (snapshot.hasData) {
            final streetDocs = snapshot.data!.docs;
            if (streetDocs.isEmpty) {
              return const Center(
                child: Text('No documents found'),
              );
            }
            return ListView.builder(
              itemCount: streetDocs.length,
              itemBuilder: (context, index) {
                final streetDoc = streetDocs[index];
                Map<String, dynamic> data =
                    streetDoc.data() as Map<String, dynamic>;
                return Card(
                  child: ListTile(
                    title: Text(
                      data['Title'],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) => UpdateData(
                                initialTitle: data['Title'],
                                onUpdate: (newTitle) {
                                  _updateData(streetDoc.id, newTitle);
                                },
                              ),
                            );
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Delete Data'),
                                content: const Text(
                                    'Are you sure you want to delete this data?'),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(),
                                    child: const Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      _deleteData(streetDoc.id);
                                      Navigator.of(context).pop();
                                    },
                                    child: const Text('Delete'),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => HouseNumberPage(
                            districtDocId: widget.districtDocId,
                            residentDocId: widget.residentDocId,
                            streetDocId: streetDoc.id,
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            );
          }
          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => CreateData(
              onCreate: _createData,
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class HouseNumberPage extends StatefulWidget {
  final String districtDocId;
  final String residentDocId;
  final String streetDocId;

  const HouseNumberPage({
    Key? key,
    required this.districtDocId,
    required this.residentDocId,
    required this.streetDocId,
  }) : super(key: key);

  @override
  _HouseNumberPageState createState() => _HouseNumberPageState();
}

class _HouseNumberPageState extends State<HouseNumberPage> {
  Stream<QuerySnapshot>? _houseNumberDocsStream;
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  Future<void> _createData(String title) async {
    try {
      await FirebaseFirestore.instance
          .collection('Districts')
          .doc(widget.districtDocId)
          .collection('Residential Area')
          .doc(widget.residentDocId)
          .collection('Street')
          .doc(widget.streetDocId)
          .collection('House Number')
          .add({'Title': title});

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Data created successfully!'),
        ),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to create data.'),
        ),
      );
    }
  }

  Future<void> _updateData(String houseNumberDocId, String newTitle) async {
    try {
      await FirebaseFirestore.instance
          .collection('Districts')
          .doc(widget.districtDocId)
          .collection('Residential Area')
          .doc(widget.residentDocId)
          .collection('Street')
          .doc(widget.streetDocId)
          .collection('House Number')
          .doc(houseNumberDocId)
          .update({'Title': newTitle});

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Data updated successfully!'),
        ),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to update data.'),
        ),
      );
    }
  }

  Future<void> _deleteData(String houseNumberDocId) async {
    try {
      await FirebaseFirestore.instance
          .collection('Districts')
          .doc(widget.districtDocId)
          .collection('Residential Area')
          .doc(widget.residentDocId)
          .collection('Street')
          .doc(widget.streetDocId)
          .collection('House Number')
          .doc(houseNumberDocId)
          .delete();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Data deleted successfully!'),
        ),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to delete data.'),
        ),
      );
    }
  }

  void _performSearch(String query) {
    setState(() {
      _houseNumberDocsStream = FirebaseFirestore.instance
          .collection('Districts')
          .doc(widget.districtDocId)
          .collection('Residential Area')
          .doc(widget.residentDocId)
          .collection('Street')
          .doc(widget.streetDocId)
          .collection('House Number')
          .where('Title', isGreaterThanOrEqualTo: query)
          .snapshots();
    });
  }

  void _clearSearch() {
    setState(() {
      _searchController.clear();
      _isSearching = false;
      _houseNumberDocsStream = FirebaseFirestore.instance
          .collection('Districts')
          .doc(widget.districtDocId)
          .collection('Residential Area')
          .doc(widget.residentDocId)
          .collection('Street')
          .doc(widget.streetDocId)
          .collection('House Number')
          .orderBy('Title', descending: false)
          .snapshots();
    });
  }

  @override
  void initState() {
    super.initState();
    _houseNumberDocsStream = FirebaseFirestore.instance
        .collection('Districts')
        .doc(widget.districtDocId)
        .collection('Residential Area')
        .doc(widget.residentDocId)
        .collection('Street')
        .doc(widget.streetDocId)
        .collection('House Number')
        .orderBy('Title', descending: false)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                onChanged: _performSearch,
                decoration: const InputDecoration(
                  hintText: 'Search...',
                  hintStyle: TextStyle(color: Colors.white),
                ),
                style: const TextStyle(color: Colors.white),
              )
            : const Text('House Number'),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) {
                  _clearSearch();
                }
              });
            },
            icon: Icon(
              _isSearching ? Icons.close : Icons.search,
            ),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _houseNumberDocsStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: Text('Something went wrong'),
            );
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          if (snapshot.hasData) {
            final houseNumberDocs = snapshot.data!.docs;
            if (houseNumberDocs.isEmpty) {
              return const Center(
                child: Text('No documents found'),
              );
            }
            return ListView.builder(
              itemCount: houseNumberDocs.length,
              itemBuilder: (context, index) {
                final houseNumberDoc = houseNumberDocs[index];
                Map<String, dynamic> data =
                    houseNumberDoc.data() as Map<String, dynamic>;
                return Card(
                  child: ListTile(
                    title: Text(
                      data['Title'],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) => UpdateData(
                                initialTitle: data['Title'],
                                onUpdate: (newTitle) {
                                  _updateData(houseNumberDoc.id, newTitle);
                                },
                              ),
                            );
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Delete Data'),
                                content: const Text(
                                    'Are you sure you want to delete this data?'),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(),
                                    child: const Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      _deleteData(houseNumberDoc.id);
                                      Navigator.of(context).pop();
                                    },
                                    child: const Text('Delete'),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BillDetailPage(
                            districtDocId: widget.districtDocId,
                            residentDocId: widget.residentDocId,
                            streetDocId: widget.streetDocId,
                            houseNumberDocId: houseNumberDoc.id,
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            );
          }
          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => CreateData(
              onCreate: _createData,
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class CreateData extends StatefulWidget {
  final Function(String title) onCreate;

  const CreateData({
    Key? key,
    required this.onCreate,
  }) : super(key: key);

  @override
  _CreateDataState createState() => _CreateDataState();
}

class _CreateDataState extends State<CreateData> {
  final _titleController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Create Data'),
      content: TextField(
        controller: _titleController,
        decoration: const InputDecoration(
          labelText: 'Title',
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            widget.onCreate(_titleController.text);
            Navigator.of(context).pop();
          },
          child: const Text('Create'),
        ),
      ],
    );
  }
}

class UpdateData extends StatefulWidget {
  final String initialTitle;
  final Function(String newTitle) onUpdate;

  const UpdateData({
    Key? key,
    required this.initialTitle,
    required this.onUpdate,
  }) : super(key: key);

  @override
  _UpdateDataState createState() => _UpdateDataState();
}

class _UpdateDataState extends State<UpdateData> {
  final _titleController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _titleController.text = widget.initialTitle;
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Update Data'),
      content: TextField(
        controller: _titleController,
        decoration: const InputDecoration(
          labelText: 'Title',
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            widget.onUpdate(_titleController.text);
            Navigator.of(context).pop();
          },
          child: const Text('Update'),
        ),
      ],
    );
  }
}

class Bill {
  final String accountId;
  final String accountCurrentMeterReading;

  Bill({
    required this.accountId,
    required this.accountCurrentMeterReading,
  });
}

class BillDetailPage extends StatefulWidget {
  final String districtDocId;
  final String residentDocId;
  final String streetDocId;
  final String houseNumberDocId;

  const BillDetailPage({
    Key? key,
    required this.districtDocId,
    required this.residentDocId,
    required this.streetDocId,
    required this.houseNumberDocId,
  }) : super(key: key);

  @override
  _BillDetailPageState createState() => _BillDetailPageState();
}

class _BillDetailPageState extends State<BillDetailPage> {
  late Stream<List<Bill>> _billDocsStream;

  Future<void> _updateMeterReading(String accountId, String newReading) async {
    try {
      await FirebaseFirestore.instance
          .collection('Districts')
          .doc(widget.districtDocId)
          .collection('Residential Area')
          .doc(widget.residentDocId)
          .collection('Street')
          .doc(widget.streetDocId)
          .collection('House Number')
          .doc(widget.houseNumberDocId)
          .collection('Bill')
          .doc(accountId)
          .update({'Account_CurrentMeterReading': newReading});

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Meter reading updated successfully!'),
        ),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to update meter reading.'),
        ),
      );
    }
  }

  Future<void> _deleteMeterReading(String accountId) async {
    try {
      await FirebaseFirestore.instance
          .collection('Districts')
          .doc(widget.districtDocId)
          .collection('Residential Area')
          .doc(widget.residentDocId)
          .collection('Street')
          .doc(widget.streetDocId)
          .collection('House Number')
          .doc(widget.houseNumberDocId)
          .collection('Bill')
          .doc(accountId)
          .delete();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Meter reading deleted successfully!'),
        ),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to delete meter reading.'),
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _billDocsStream = FirebaseFirestore.instance
        .collection('Districts')
        .doc(widget.districtDocId)
        .collection('Residential Area')
        .doc(widget.residentDocId)
        .collection('Street')
        .doc(widget.streetDocId)
        .collection('House Number')
        .doc(widget.houseNumberDocId)
        .collection('Bill')
        .snapshots()
        .map((querySnapshot) => querySnapshot.docs.map((doc) {
              Map<String, dynamic> data = doc.data();
              return Bill(
                accountId: doc.id,
                accountCurrentMeterReading:
                    data['Account_CurrentMeterReading'],
              );
            }).toList());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bill'),
        centerTitle: true,
      ),
      body: StreamBuilder<List<Bill>>(
        stream: _billDocsStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: Text('Something went wrong'),
            );
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          if (snapshot.hasData) {
            final List<Bill> billDocs = snapshot.data!;
            if (billDocs.isEmpty) {
              return const Center(
                child: Text('No documents found'),
              );
            }
            return ListView.builder(
              itemCount: billDocs.length,
              itemBuilder: (context, index) {
                final Bill bill = billDocs[index];
                return Card(
                  child: ListTile(
                    title: Text(
                      'Current Meter Reading: ${bill.accountCurrentMeterReading}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) => UpdateBill(
                                initialReading: bill.accountCurrentMeterReading,
                                onUpdate: (newReading) {
                                  _updateMeterReading(
                                    bill.accountId,
                                    newReading,
                                  );
                                },
                              ),
                            );
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Delete Meter Reading'),
                                content: const Text(
                                    'Are you sure you want to delete this meter reading?'),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(),
                                    child: const Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      _deleteMeterReading(bill.accountId);
                                      Navigator.of(context).pop();
                                    },
                                    child: const Text('Delete'),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }
          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => CreateData(
              onCreate: (title) {
                FirebaseFirestore.instance
                    .collection('Districts')
                    .doc(widget.districtDocId)
                    .collection('Residential Area')
                    .doc(widget.residentDocId)
                    .collection('Street')
                    .doc(widget.streetDocId)
                    .collection('House Number')
                    .doc(widget.houseNumberDocId)
                    .collection('Bill')
                    .add({
                  'Account_CurrentMeterReading': title,
                }).then((docRef) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Data created successfully!'),
                    ),
                  );
                }).catchError((error) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Failed to create data.'),
                    ),
                  );
                });
              },
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class UpdateBill extends StatefulWidget {
  final String initialReading;
  final Function(String newReading) onUpdate;

  const UpdateBill({
    Key? key,
    required this.initialReading,
    required this.onUpdate,
  }) : super(key: key);

  @override
  _UpdateBillState createState() => _UpdateBillState();
}

class _UpdateBillState extends State<UpdateBill> {
  final _newReadingController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _newReadingController.text = widget.initialReading;
  }

  @override
  void dispose() {
    _newReadingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Update Meter Reading'),
      content: TextField(
        controller: _newReadingController,
        decoration: const InputDecoration(
          labelText: 'New Reading',
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            widget.onUpdate(_newReadingController.text);
            Navigator.of(context).pop();
          },
          child: const Text('Update'),
        ),
      ],
    );
  }
}