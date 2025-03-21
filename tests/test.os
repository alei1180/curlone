#Использовать ".."


Нач = ТекущаяУниверсальнаяДатаВМиллисекундах();


КонсольнаяКоманда = "curl http://example1.com/ -F name=John -F shoesize=11
|curl http://example2.com/ -F profile=@portrait.jpg
|curl http://example3.com/ -F profile=@portrait.jpg --form brief=@file.pdf
|curl http://example4.com/ -F file=@part1 --form file=@part2
|curl http://example5.com/ -F name=John -F profile=@portrait.jpg
|curl http://example6.com/ -F story=<hugefile.txt
|curl http://example7.com/ -F 'web=@index.html;type=text/html'
|curl http://example8.com/ -F 'name=daniel;type=text/foo'
|curl http://example9.com/ -F ""file=@localfile;filename=nameinpost""
|curl http://example10.com/ -F ""file=@\""local,file\"";filename=\""name;in;post\""""
|curl http://example11.com/ -F ""colors=\""red; green; blue\"";type=text/x-myapp""
|curl http://example12.com/ -F ""submit=OK;headers=\""X-submit-type: OK\""""
|curl http://example13.com/ -F ""json=@data.json;headers=\""X-header: value\""""
|curl http://example14.com/ -F ""json=@data.json;headers=\""X-header-1: some value 1\"";headers=\""X-header-2: some value 2\""""
|curl http://example15.com/ --form-string name=data
|curl http://example16.com/ --form-string name=@data;type=some
|curl http://example17.com/ -F name=John= -F brief=doctor=111;type=text/foo
|curl http://example18.com/ -F profile=@portrait.jpg;type=text/html,@file1.pdf,@file2.pdf;type=text/xml";

К = Новый КонвертерКомандыCURL();
К.УстановитьЯзыкПеревода("ru");
Перевод = К.Конвертировать(КонсольнаяКоманда);
Сообщить(ТекущаяУниверсальнаяДатаВМиллисекундах() - нач);

