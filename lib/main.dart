import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_svg/svg.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:fluttertoast/fluttertoast.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Origam Sistemas',
      theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.green)),
      home: const MyHomePage(title: 'Teste'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List data = [];

  int letras = 0;

  String textFieldTweet = '';

  final tweetField = TextEditingController();

  Future<void> _launchLinkedin() async {
    if (!await launchUrl(Uri.parse('https://linkedin.com'))) {
      throw Exception('Não conseguimos acessar o Linkedin');
    }
  }

  Future<void> _launchInsta() async {
    if (!await launchUrl(Uri.parse('https://instagram.com'))) {
      throw Exception('Não conseguimos acessar o Instagram');
    }
  }

  Future<void> _launchPortfolio() async {
    if (!await launchUrl(Uri.parse('https://google.com'))) {
      throw Exception('Não conseguimos acessar o Portfolio');
    }
  }

  void _mudarLength(length) {
    setState(() {
      letras = length;
    });
  }

  void pegarTextoTweet(texto) {
    setState(() {
      textFieldTweet = texto;
    });
  }

  @override
  void initState() {
    super.initState();
    fetchPosts();
  }

  Future<void> fetchPosts() async {
    final response =
        await http.get(Uri.https('exam-api.origam.services', '/api/posts/'));

    if (response.statusCode == 200) {
      setState(() {
        data = jsonDecode(response.body);
      });
    } else {
      setState(() {
        data.add('Erro na requisição');
      });
    }
  }

  Future<void> deletePost(id) async {
    final response = await http
        .delete(Uri.https('exam-api.origam.services', '/api/posts/${id}'));

    if (response.statusCode == 200) {
      print('sucesso');
      fetchPosts();
    } else {
      print('error');
    }
  }

  Future<void> postarTweet(String tweet) async {
    Map data = {'title': tweet};

    var body = jsonEncode(data);

    final response = await http.post(
      Uri.https('exam-api.origam.services', '/api/posts/'),
      headers: {"Content-Type": "application/json"},
      body: body,
    );

    if (response.statusCode == 201) {
      print('sucesso');
      fetchPosts();
    } else {
      print('error');
    }
  }

  void limpaText() {
    tweetField.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appBar(),
      body: ListView(
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        children: [
          const SizedBox(
            height: 40,
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _perfilBox(),
              Expanded(
                flex: 1,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _textFieldPublicar(),
                    SizedBox(
                      height: 40,
                    ),
                    Text(
                      'Minhas publicações',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 24,
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Container(
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            offset: Offset(5, 5),
                            blurRadius: 5,
                          )
                        ],
                      ),
                      child: Column(
                        children: [
                          ListView.separated(
                            scrollDirection: Axis.vertical,
                            shrinkWrap: true,
                            itemBuilder: (context, index) {
                              return Container(
                                margin: EdgeInsets.only(right: 40),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 5,
                                      offset: Offset(5, 5),
                                    )
                                  ],
                                ),
                                padding: EdgeInsets.all(10),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(26),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            children: [
                                              CircleAvatar(
                                                radius: 25,
                                                backgroundImage: AssetImage(
                                                    'assets/images/avatar.png'),
                                              ),
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text('Jane Cooper'),
                                                  Text('1h Atrás'),
                                                ],
                                              ),
                                            ],
                                          ),
                                          PopupMenuButton(onSelected: (value) {
                                            if (value == 'Excluir') {
                                              deletePost(data[index]['id']);
                                            }
                                          }, itemBuilder: (context) {
                                            return [
                                              PopupMenuItem(
                                                value: 'Excluir',
                                                child: Text('Excluir'),
                                              ),
                                              PopupMenuItem(
                                                  value: 'Editar',
                                                  child: Text('Editar'))
                                            ];
                                          })
                                        ],
                                      ),
                                    ),
                                    Column(
                                      children: [
                                        Text(
                                          data[index]['title'].toString(),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            },
                            separatorBuilder: (context, index) => SizedBox(
                              height: 16,
                            ),
                            itemCount: data.length,
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
          SizedBox(
            height: 100,
          )
        ],
      ),
    );
  }

// Criando as notificações para cada caso
// Toast Sucesso
  showSucess(BuildContext context) {
    FToast fToast = FToast();
    fToast.init(context);
    Widget toast = Container(
      width: 350,
      height: 75,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        color: Colors.green,
      ),
      child: Row(
        children: [
          Icon(
            Icons.check,
            color: Colors.white,
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Postagem realizada com sucesso!',
              style: TextStyle(
                color: Colors.white,
              ),
            ),
          ),
          Icon(
            Icons.close,
            color: Colors.white,
          ),
        ],
      ),
    );
    fToast.showToast(
      child: toast,
      toastDuration: const Duration(seconds: 5),
      gravity: ToastGravity.TOP_RIGHT,
      isDismissable: true,
    );
  }

// Toast Error
  showError(BuildContext context) {
    FToast fToast = FToast();
    fToast.init(context);
    Widget toast = Container(
      width: 350,
      height: 75,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        color: Colors.green,
      ),
      child: Row(
        children: [
          Icon(
            Icons.check,
            color: Colors.white,
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Postagem excluída com sucesso!',
              style: TextStyle(
                color: Colors.white,
              ),
            ),
          ),
          Icon(
            Icons.close,
            color: Colors.white,
          ),
        ],
      ),
    );
    fToast.showToast(
      child: toast,
      toastDuration: const Duration(seconds: 5),
      gravity: ToastGravity.TOP_RIGHT,
      isDismissable: true,
    );
  }

// Toast Update
  showUpdate(BuildContext context) {
    FToast fToast = FToast();
    fToast.init(context);
    Widget toast = Container(
      width: 350,
      height: 75,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        color: Colors.green,
      ),
      child: Row(
        children: [
          Icon(
            Icons.check,
            color: Colors.white,
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Postagem atualizada com sucesso!',
              style: TextStyle(
                color: Colors.white,
              ),
            ),
          ),
          Icon(
            Icons.close,
            color: Colors.white,
          ),
        ],
      ),
    );
    fToast.showToast(
      child: toast,
      toastDuration: const Duration(seconds: 5),
      gravity: ToastGravity.TOP_RIGHT,
      isDismissable: true,
    );
  }

  Container _textFieldPublicar() {
    return Container(
      height: 350,
      margin: const EdgeInsets.only(right: 40),
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 5,
            offset: const Offset(5, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          TextField(
            controller: tweetField,
            onChanged: (value) {
              _mudarLength(value.length);
              pegarTextoTweet(value);
            },
            maxLength: 280,
            maxLines: 5,
            decoration: InputDecoration(
              hintText: 'O que está pensando?',
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(
                  color: Colors.grey,
                  width: 2,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(
                  color: Colors.grey,
                  width: 2,
                ),
              ),
              contentPadding: const EdgeInsets.all(15),
              fillColor: Colors.white,
              filled: true,
            ),
          ),
          const SizedBox(
            height: 40,
          ),
          InkWell(
            mouseCursor: letras == 0
                ? SystemMouseCursors.basic
                : SystemMouseCursors.click,
            onTap: () {
              if (letras == 0) {
              } else {
                postarTweet(textFieldTweet);
                limpaText();
                fetchPosts();
                showSucess(context);
              }
            },
            child: Container(
              padding: const EdgeInsets.only(
                top: 20,
                bottom: 20,
                right: 40,
                left: 40,
              ),
              decoration: letras == 0
                  ? BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(10),
                    )
                  : BoxDecoration(
                      color: const Color.fromRGBO(113, 120, 6, 1),
                      borderRadius: BorderRadius.circular(10),
                    ),
              child: Text(
                'Publicar',
                style: TextStyle(
                  fontSize: 18,
                  color: letras == 0 ? Colors.grey.shade700 : Colors.white,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Container _perfilBox() {
    return Container(
      width: 300,
      margin: EdgeInsets.only(left: 40, right: 40),
      padding: EdgeInsets.only(top: 40, bottom: 40),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            spreadRadius: 5,
            blurRadius: 10,
            offset: Offset(0, 0),
          )
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(
            width: 120,
            height: 120,
            child: CircleAvatar(
              radius: 50.0,
              backgroundImage: AssetImage('assets/images/avatar.png'),
            ),
          ),
          const Text(
            'Jane Cooper',
            style: TextStyle(
              fontSize: 32,
              color: Color.fromRGBO(25, 25, 30, 1),
              fontWeight: FontWeight.w500,
            ),
          ),
          const Text(
            'Front-end Developer',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Padding(padding: EdgeInsets.only(top: 15)),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(
                'assets/images/localizacao.svg',
                fit: BoxFit.contain,
                color: Colors.grey,
              ),
              const Padding(padding: EdgeInsets.only(left: 5)),
              const Text(
                'São Roque, São Paulo',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            width: 250,
            height: 45,
            decoration: BoxDecoration(
              border: Border.all(
                width: 1,
                color: Color.fromRGBO(113, 120, 6, 1),
              ),
              borderRadius: BorderRadius.circular(5),
            ),
            child: ElevatedButton(
              style: ButtonStyle(
                overlayColor: WidgetStateColor.resolveWith(
                  (value) => Colors.transparent,
                ),
                shadowColor: WidgetStateColor.resolveWith(
                  (value) => Colors.transparent,
                ),
                backgroundColor:
                    WidgetStateColor.resolveWith((context) => Colors.white),
              ),
              onPressed: () {
                print('Press me!');
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset('assets/images/lapis.svg'),
                  SizedBox(
                    width: 5,
                  ),
                  Text(
                    'Editar perfil',
                    style: TextStyle(
                      color: Color.fromRGBO(113, 120, 6, 1),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            height: 20,
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(
                width: 2,
                color: Colors.grey,
                style: BorderStyle.solid,
              ),
              borderRadius: BorderRadius.circular(5),
            ),
            child: Column(
              children: [
                _ButtonPortfolio(),
                Container(
                  width: 250,
                  child: Divider(
                    height: 2,
                    color: Colors.grey,
                    thickness: 2,
                  ),
                ),
                _ButtonLinkedin(),
                Container(
                  width: 250,
                  child: Divider(
                    height: 2,
                    color: Colors.grey,
                    thickness: 2,
                  ),
                ),
                _ButtonInsta(),
              ],
            ),
          )
        ],
      ),
    );
  }

  InkWell _ButtonPortfolio() {
    return InkWell(
      onTap: _launchPortfolio,
      child: Container(
        height: 45,
        width: 250,
        padding: EdgeInsets.only(left: 10, right: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Portfólio',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 18,
              ),
            ),
            SvgPicture.asset(
              'assets/images/newpage.svg',
              height: 22,
            ),
          ],
        ),
      ),
    );
  }

  InkWell _ButtonInsta() {
    return InkWell(
      onTap: _launchInsta,
      child: Container(
        height: 45,
        width: 250,
        padding: EdgeInsets.only(left: 10, right: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Instagram',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 18,
              ),
            ),
            SvgPicture.asset(
              'assets/images/newpage.svg',
              height: 22,
            ),
          ],
        ),
      ),
    );
  }

  InkWell _ButtonLinkedin() {
    return InkWell(
      onTap: _launchLinkedin,
      child: Container(
        height: 45,
        width: 250,
        padding: EdgeInsets.only(left: 10, right: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'LinkedIn',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 18,
              ),
            ),
            SvgPicture.asset(
              'assets/images/newpage.svg',
              height: 22,
            ),
          ],
        ),
      ),
    );
  }

  AppBar _appBar() {
    return AppBar(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      toolbarHeight: 80,
      shadowColor: Colors.black.withOpacity(0.2),
      elevation: 15,
      title: Container(
        padding: EdgeInsets.only(top: 50, bottom: 50),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Container(
              height: 45,
              child: SvgPicture.asset(
                'assets/images/logo.svg',
                fit: BoxFit.fitHeight,
              ),
            ),
            Container(
              height: 45,
              width: 300,
              padding: EdgeInsets.only(
                left: 15,
                right: 25,
              ),
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
                border: Border.all(color: Colors.grey, width: 1),
                borderRadius: BorderRadius.circular(5),
                color: Colors.white,
              ),
              child: TextField(
                decoration: InputDecoration(
                  prefixIcon: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SvgPicture.asset(
                        matchTextDirection: true,
                        'assets/images/lupa.svg',
                        alignment: Alignment.center,
                        height: 15,
                        fit: BoxFit.contain,
                      ),
                    ],
                  ),
                  hintText: 'Pesquisar',
                  border: InputBorder.none,
                ),
                style: TextStyle(
                  fontSize: 18,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
