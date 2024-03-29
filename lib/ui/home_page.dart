import 'dart:io';

import 'package:flutter/material.dart';
import 'package:projeto_rpg_manager/helpers/jogador_helper.dart';
import 'package:projeto_rpg_manager/pages/alarm.dart';
import 'package:projeto_rpg_manager/ui/jogador_page.dart';
import 'package:url_launcher/url_launcher.dart';

enum OrderOptions {orderaz, orderza,alarm}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int AzulPetrolioLight = 0xFF110274;
  int AzulPetrolio = 0xff040b28;

  JogadorHelper helper = JogadorHelper();

  List<Jogador> jogador = [];

  @override
  void initState() {
    super.initState();
    _getAllJogadores();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Jogadores"),
        backgroundColor: Colors.blue,
        centerTitle: true,
        actions: <Widget>[
          PopupMenuButton<OrderOptions>(
              itemBuilder: (context) => <PopupMenuEntry<OrderOptions>>[
                const PopupMenuItem(
                    child: Text("Ordenar de A-Z"),
                    value: OrderOptions.orderaz,
                ),
                const PopupMenuItem(
                  child: Text("Ordenar de Z-A"),
                  value: OrderOptions.orderza,
                ),
                /*const PopupMenuItem(
                  child: Text("Alarm"),
                  value: OrderOptions.alarm,
                ),*/
              ],
            onSelected: _orderList,
          )
        ],
      ),
      backgroundColor: Colors.white,
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          _showJogadorPage();
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.blue,
      ),
      body: ListView.builder(
          padding: EdgeInsets.all(10.0),
          itemCount: jogador.length,
          itemBuilder: (context, Index){
            return _jogadorCard(context, Index);
          }
      ),
    );
  }

  Widget _jogadorCard(BuildContext context, int index){
    return GestureDetector(
      child: Card(
        child: Padding(
          padding: EdgeInsets.all(10.0),
          child: Row(
            children:<Widget> [
              Container(
                width: 80.0,
                height: 80.0,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    image: jogador[index].img != null ?
                        FileImage(File(jogador[index].img!)) :
                          AssetImage("images/megaman-x.jpg") as ImageProvider
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: 10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children:<Widget>[
                    Text(jogador[index].jogador ?? "",
                    style: TextStyle(fontSize: 22.0,
                        fontWeight: FontWeight.bold),
                    ),
                    Text("P: ${jogador[index].nome ?? ""}",
                      style: TextStyle(fontSize: 18.0,),
                    ),
                    Text("Lv: ${jogador[index].nivel ?? "1"}",
                      style: TextStyle(fontSize: 18.0,),
                    ),
                    Text("R: ${jogador[index].raca ?? ""}",
                      style: TextStyle(fontSize: 18.0,),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
      onTap: (){
        _showOptions(context, index);
      },
    );
  }
  void _showOptions(BuildContext context, int index){
    showModalBottomSheet(
        context: context,
        builder: (context){
          return BottomSheet(
              onClosing: (){},
              builder: (context){
                return Container(
                  padding: EdgeInsets.all(10.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.all(10.0),
                        child:    TextButton(
                          child: Text("ligar",
                            style: TextStyle(color: Colors.blue, fontSize: 20.0),
                          ),
                          onPressed: (){
                            setState((){
                              showReview(context,
                                "Essa função ainda esta em desenvovimento",
                                "images/megaman-x.jpg",
                                "Ok",
                                    () {
                                  Navigator.of(context).pop();
                                },
                              );
                            });
                            /*launchUrl(Uri.parse("tel:${contacts[index].phone}"));*/ //numero de telefone
                          },
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(10.0),
                        child:    TextButton(
                          child: Text("Ver Ficha",
                            style: TextStyle(color: Colors.blue, fontSize: 20.0),
                          ),
                          onPressed: (){
                            Navigator.pop(context);
                            _showJogadorPage(jogador: jogador[index]);
                          },
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(10.0),
                        child:    TextButton(
                          child: Text("Excluir",
                            style: TextStyle(color: Colors.blue, fontSize: 20.0),
                          ),
                          onPressed: (){
                            helper.deleteJogador(jogador[index].id!);
                            setState(() {
                              jogador.removeAt(index);
                              Navigator.pop(context);
                            });
                          },
                        ),
                      ),
                   ],
                  ),
                );
              });
        }
    );
  }
  void _showJogadorPage({Jogador? jogador}) async {
    print(jogador);
   final recJogador = await Navigator.push(context,
      MaterialPageRoute(builder: (context) => JogadorPage(jogador: jogador,))
    );
   if(recJogador != null){
     if(jogador != null){
       print("atualizar");
       await helper.updateJogador(recJogador);
       _getAllJogadores();
     }else{
       await helper.saveJogador(recJogador);
       _getAllJogadores();
     }
   }
  }
  void _getAllJogadores(){
    helper.getAllJogador().then((list){
      setState(() {
        jogador = list.cast<Jogador>();
      });
    });
  }
  void _orderList(OrderOptions result){
    switch(result){
      case OrderOptions.orderaz:
        jogador.sort((a, b){
         return a.jogador!.toLowerCase().compareTo(b.jogador!.toLowerCase());
        });
        break;
      case OrderOptions.orderza:
        jogador.sort((a, b){
         return b.jogador!.toLowerCase().compareTo(a.jogador!.toLowerCase());
        });
        break;
      case OrderOptions.alarm:
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => Alarm_page())
        );
        break;
    }
    setState(() {

    });
  }
  showReview(context, String mensagem, String pit, String textbtn, rota, {bool clickFora = true}) {
    showDialog(
        context: context,
        barrierDismissible: clickFora,
        builder: (BuildContext context) {
          return Dialog(
            shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
            child: Container(
              height: 350,
              decoration:
              BoxDecoration(borderRadius: BorderRadius.circular(20.0)),
              child: Column(
                children: <Widget>[
                  Container(
                    width: MediaQuery.of(context).size.width,
                    height: 50.0,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(10.0),
                          topRight: Radius.circular(10.0)),
                      color: Color(AzulPetrolio),
                    ),
                  ),

                  SizedBox(height: 20.0),
                  Padding(
                      padding: EdgeInsets.all(10.0),
                      child: Text(
                        mensagem, //mensagem referente a resposta
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Quicksand',
                          fontSize: 20.0,
                          fontWeight: FontWeight.w300,
                        ),
                      )),

                  Image.asset(
                    pit,
                    height: 100,
                  ), //carinha do pit

                  TextButton(
                      child: Center(
                        child: Text(
                          textbtn, //nome do botão
                          style: TextStyle(
                              fontFamily: 'Montserrat',
                              fontSize: 20.0,
                              color: Colors.blue),
                        ),
                      ),
                      onPressed: rota, //caminho apos o botão ser clicado
                      style: TextButton.styleFrom(
                          backgroundColor: Colors.transparent))
                ],
              ),
            ),
          );
        });
  }
}
