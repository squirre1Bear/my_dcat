import 'dart:convert';   // 解码用的（包含UTF-8）
import 'dart:io';   // 操作文件
import 'package:args/args.dart';   // 这个需要获取依赖项
/*
$ dart create dcat
$ cd dcat
$ dart pub add args
*/

const lineNumber = 'line-number';
void main(List<String> atguments) {
    exitCode = 0;
    //创建ArgParser对象（用于解析命令行参数）并添加标志（通过lineNumber相关联） abbr:'n'表示这个标志可以用-n作为缩写
    final paser = ArgParser()..addFlag(lineNumber, negatable: false, abbr: 'n');
    // 解析命令行参数，保存在arg..中
    ArgResults argResults = parser.parse(arguments);
    // .rest包含没有被解析为命令的命令行参数，一般是文件路径
    final paths = argResults.rest;
    // 传进去path，并显示行号
    dcat(paths, showLineNumbers: argResults[lineNumber] as bool);

}

// 定义异步函数
// 当成功返回数据的时候才会完成这个函数，返回类型为void
Future<void> dcat(List<String> paths, {bool showLineNumbers = false}) async {
    if(paths.isEmpty) {
        // 如果输入的path为空，则从标准输入流中读入（从命令行传入）路径
        // pipe()是将两个流连接到一起，流入前面的数据会自动传输到后面的流（stdout,标准输出流）
        await stdin.pipe(stdout);
    } else{
        for(final path in paths) {
            var lineNumber = 1;    // 行号从1开始编
            final lines = utf8.decoder
                .bind(File(path).openRead())  // 把文件读入的数据接到解码器（变为utf8）
                .transform(const LineSplitter());    // 将字符串流转换为单独的行
            try {
                await for (final line in lines) {
                    if (showLineNumbers) {
                        stdout.write('${lineNumber++}');
                    }
                    stdout.writeln(line);
                }
            } catch(_) {    // 出现异常
                await _handleError(path);
            }
        }
    }
}

Future<void> _handleError(String path) async {
    if (await FileSystemEntity.isDirectory(path)) {
        stderr.writeln('error: $path is a directory');
    } else {
        exitCode = 2;
    }
}