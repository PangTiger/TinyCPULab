# 自己动手写CPU-实验四-综合实验
by CPU兴趣小组

## 内容
本次实验是最后一次实验，对于选了``创新技能训练``这门课的同学，本次实验是关系到这门课分数的最终考核，我们会根据大家的完成情况进行给分。其他没有选这门课的同学，本次实验就是一次普普通通平凡无奇的实验。经过前面几次实验，大家应该对CPU的架构和代码有了一定的了解，添加这五条指令应该不是问题:)

本次实验需要在3小时内实现指定的五条指令。他们分别是
```
SLTI
XORI
SUB
MULTU
BLTZ
```

## 源代码
源代码已经上传到``Lab4_Final/Src_Realease``文件夹下，这份代码解决了简单情况下的数据前推，但是没有实现转移指令。需要参加``创新技能训练``这门课的考核的同学请务必在这份源代码的基础上进行修改。其他同学可以按照自己已有版本的源代码添加功能。

## 需要的文档
目前所有的文档放置在``TinyCPULab/Common_Docs``文件夹下，你可能需要用到：
1. 龙芯提供的MIPS指令系统规范_v1.00
2. 我们提供的CPU控制信号的编码表

## 测试汇编代码&Testbench
汇编代码如下，大家可以使用MARZ辅助判断CPU执行的结果。
```
#Test case 1
lui $t1,0xfedc	# Register 9 (t1) should be 0xfedc0000
slti $t2,$t1,0x0001 # Register 10 (t2) should be 0x0001
nop
nop
nop
nop
#Test case 2
ori $at,$t1,0x1234  # Register 1 (at) should be 0xfedc1234
xori $t3,$at,0x5678 # Register 11 (t3) should be 0xfedc444c
nop
nop
nop
nop
#Test case 3
ori $v0,$zero,0x2333 # Register 2 (v0) should be 0x2333
multu $at,$v0        # hi should be 0x230a, lo should be 0xdc54bc5c
nop
nop
nop
nop
nop
mfhi $t4             # Register 12 (t4) should be 0x0000230a
mflo $t5             # Register 13 (t5) should be 0xdc54bc5c
#Test case 4
sub $t6,$at,$v0      # Register 14 (t6) should be 0xfedbef01
nop
nop
#Test case 5
bltz $t1,L1
nop
lui $t7,0x1111       # cpu should skip this instruction
L1:
ori $t7,0x8888       # Register 15 (t7) should be 0x8888
```

同时，最新版的``im.sv``（指令存储器）文件也进行了更新，使用自己版本源代码的同学需要拷贝一下最新的``im.sv``。
## 分数评定
3小时内实现的指令越多分数则越高。