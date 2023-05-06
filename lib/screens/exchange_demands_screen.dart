import 'package:book_mingle_ui/models/exchange_demand_model.dart';
import 'package:book_mingle_ui/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class ExchangeDemandsScreen extends StatefulWidget {
  const ExchangeDemandsScreen({Key? key}) : super(key: key);

  @override
  State<ExchangeDemandsScreen> createState() => _ExchangeDemandsScreenState();
}

class _ExchangeDemandsScreenState extends State<ExchangeDemandsScreen> {
  final RefreshController _refreshController =
      RefreshController(initialRefresh: true);
  int _currentPage = 0;
  bool _hasNextPage = true;
  List<ExchangeDemandResponse> _exchangeDemandItems = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: SafeArea(
        child: SmartRefresher(
          controller: _refreshController,
          header: const WaterDropHeader(),
          footer: const ClassicFooter(
            loadStyle: LoadStyle.ShowWhenLoading,
          ),
          onRefresh: _onRefresh,
          onLoading: _onLoading,
          child: _buildListView(),
        ),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        color: Colors.grey,
        onPressed: _navigateToChatListScreen,
      ),
      backgroundColor: Colors.white,
    );
  }

  void _navigateToChatListScreen() {
    Navigator.of(context).pop();
  }

  Future<void> _onRefresh() async {
    bool isSuccessful = await _firstLoad();
    isSuccessful
        ? _refreshController.refreshCompleted()
        : _refreshController.refreshFailed();
  }

  Future<void> _onLoading() async {
    bool isSuccessful = await _loadMore();
    isSuccessful
        ? _refreshController.loadComplete()
        : _refreshController.loadNoData();
  }

  Future<bool> _firstLoad() async {
    _currentPage = 0;
    _hasNextPage = true;
    _refreshController
        .loadComplete(); // To set load more functionality available

    List<ExchangeDemandResponse> exchangeDemandListResponse =
        await ApiService.getExchangeDemands(_currentPage);
    setState(() {
      _exchangeDemandItems = exchangeDemandListResponse;
    });
    return true;
  }

  Future<bool> _loadMore() async {
    if (!_hasNextPage) {
      return false;
    }

    _currentPage++;
    List<ExchangeDemandResponse> exchangeDemandListResponse =
        await ApiService.getExchangeDemands(_currentPage);
    if (exchangeDemandListResponse.isNotEmpty) {
      setState(() {
        _exchangeDemandItems.addAll(exchangeDemandListResponse);
      });
      return true;
    }
    setState(() {
      _hasNextPage = false;
    });
    return false;
  }

  ListView _buildListView() {
    return ListView.builder(
      itemCount: _exchangeDemandItems.length,
      itemBuilder: (context, index) => GestureDetector(
        // onTap: () => _bookRequestDialog(_items[index]),
        onTap: () => _exchangeDemandResponseDialog(_exchangeDemandItems[index]),
        child: Card(
          margin: const EdgeInsets.symmetric(
            vertical: 8,
            horizontal: 10,
          ),
          child: ListTile(
            leading: CircleAvatar(
              child: Text(index.toString()),
            ),
            title: Text(_exchangeDemandItems[index].proposedBook.title),
            subtitle: Text(_exchangeDemandItems[index].proposedBook.author),
          ),
        ),
      ),
    );
  }

  void _exchangeDemandResponseDialog(
      ExchangeDemandResponse demandResponse) async {
    showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Accept request?'),
        actions: [
          TextButton(
            onPressed: () async {
              bool isSuccess = await ApiService.updateExchangeDemandStatus(
                  demandResponse.requestId, false);
              if (isSuccess) {
                showExchangeDemandResponseResultMessage(
                    'Rejected Successfully');
              } else {
                showExchangeDemandResponseResultMessage(
                    'An Error Occurred While Updating Request');
              }
            },
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () async {
              bool isSuccess = await ApiService.updateExchangeDemandStatus(
                  demandResponse.requestId, true);
              if (isSuccess) {
                showExchangeDemandResponseResultMessage(
                    'Accepted Successfully');
              } else {
                showExchangeDemandResponseResultMessage(
                    'An Error Occurred While Updating Request');
              }
            },
            child: const Text('Yes'),
          ),
        ],
      ),
    );
  }

  void showExchangeDemandResponseResultMessage(String message) {
    Navigator.pop(context);
    if (message.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }
}

/*
*
* import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Request {
  final String text;
  final bool accepted;

  Request({required this.text, required this.accepted});

  factory Request.fromJson(Map<String, dynamic> json) {
    return Request(
      text: json['text'],
      accepted: json['accepted'],
    );
  }
}

class RequestsScreen extends StatefulWidget {
  const RequestsScreen({Key? key}) : super(key: key);

  @override
  _RequestsScreenState createState() => _RequestsScreenState();
}

class _RequestsScreenState extends State<RequestsScreen> {
  List<Request> requests = [];
  int page = 1;
  bool isLoading = false;

  Future<void> fetchRequests() async {
    setState(() {
      isLoading = true;
    });

    final response = await http.get(Uri.parse('https://jsonplaceholder.typicode.com/todos?_page=$page&_limit=10'));

    setState(() {
      isLoading = false;
      page++;
      requests.addAll((json.decode(response.body) as List).map((data) => Request.fromJson(data)).toList());
    });
  }

  @override
  void initState() {
    super.initState();
    fetchRequests();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Requests'),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {
            requests.clear();
            page = 1;
          });

          await fetchRequests();
        },
        child: ListView.builder(
          itemCount: requests.length + (isLoading ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == requests.length) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }

            final request = requests[index];

            return ListTile(
              title: Text(request.text),
              onTap: () async {
                final result = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text('Accept request?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: Text('No'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: Text('Yes'),
                      ),
                    ],
                  ),
                );

                if (result != null) {
                  await http.post(Uri.parse('https://example.com/requests/${request.id}'), body: {'accepted': result.toString()});
                }
              },
            );
          },
        ),
      ),
    );
  }
}
* */
