import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class StaffBillManagement extends StatefulWidget {
  const StaffBillManagement({Key? key}) : super(key: key);

  @override
  _StaffBillManagementState createState() => _StaffBillManagementState();
}

class _StaffBillManagementState extends State<StaffBillManagement> {
  final CollectionReference _collectionRef =
      FirebaseFirestore.instance.collection('Districts');

  Stream<QuerySnapshot>? _districtsStream;
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

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