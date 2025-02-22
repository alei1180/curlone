#Использовать ".."

Парсер = Новый КонвертерКомандыCURL();
Результат = Парсер.Конвертировать("curl http://example10.com/ -F ""file=@\""local,file\"";filename=\""name;in;post\""""
|curl http://example10.com/ -F ""file=@\""local,file\"";filename=\""name;in;post\""""");
//Результат = Парсер.Конвертировать("curl http://127.0.0.1:3334/post -F 'profile=@C:\Users\Dima\Downloads\3.txt'");
Сообщить(Результат);
//КоманднаяСтрока = "myapp8 url''''";

//Парсер = Новый ПарсерКонсольнойКоманды();
//Результат = Парсер.Распарсить(КоманднаяСтрока);
C=1;
