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
汇编代码如下

## 分数评定
3小时内实现的指令越多分数则越高。