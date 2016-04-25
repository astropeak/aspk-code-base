# 打开一个输入文件
open my $fh, "<", "file.txt" or die "Can't open file";

# 打开一个输出文件
open my $fh, ">", "file.txt" or die "Can't open file";

# append
open my $fh, ">>", "file.txt" or die "Can't open file";

# open filehandle, mode, filename
# filename 可以是一个表达式。
# mode是："<", ">", ">>", "+<", "+>", "+>>"。有+号表示同时读写。

# 读取一行
my $line = <$fh>;

# 读取若干字节
# read filehandle, scalar, length, offset
# 从filehandle里，读取最多length个字符，保存在变量scalar里。如果提供了offset，则保存在变量scalar的offset 位置上。
# 返回值为实际读取的字节数目。0 如果EOL，读取错误，则为undef。
# 读取位置为未读取的第一个字符。由perl自动更新。

# binmode的作用：防止perl自动将C-MC-J 转换为\n.
binmode $fh;
$n = read $fh, $s, 4;


# 使用read函数读取文件的所有内容。
my ($n, $buf, $s);
while (($n=read $fh, $s, 4) != 0) {
    $buf.=$s;
}

# 使用第四个参数
my ($n, $s, $offset);
while (($n=read $fh, $s, 4, $offset)!=0) {
    $offset += 4;
}

# 写入文件
# 使用print函数，只不过第一个参数为filehandle. 注意第一个参数后面不加逗号。
print $fh "aaa", "bbb";







