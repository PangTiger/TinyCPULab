# 自己动手写CPU-实验三
by CPU兴趣小组

## 转移指令的实现

### 转移指令编码
下面列出的五条指令是"计算机系统设计"书中第六章实现的五条转移指令, 这五条指令如下图所示
<img src=".\fig\J.png" width="700">

<img src=".\fig\JAL1.png" width="700">

<img src=".\fig\JAL2.png" width="700">

<img src=".\fig\JAL3.png" width="700">

<img src=".\fig\BEQ.png" width="700">

<img src=".\fig\BNE.png" width="700">

<img src=".\fig\BNE2.png" width="700">

### 转移指令的分类
转移指令分为无条件转移和有条件转移. 所谓的无条件的转移就是直接跳转, 例如J JAL JR指令, 而BEQ和BNE还需要判断条件, 对rs和rt字段寄存器的值进行比较, 满足条件才发生分支. 

由指令编码可以看出, J和JAL指令都是J型指令, 而JR其实是是R型指令, BEQ和BNE是I型指令. 可以看到部分转移指令会读寄存器堆的值, 还有一些转移指令会写寄存器堆, 这些特点都要纳入设计的考虑之中.

### 原框架需要的修改

#### 译码级
##### 增加模块端口
译码级需要在原来的基础上增加接口: 转移目的地址, 是否发生转移.

##### 增加内部信号
判断是否跳转: 
1. 无条件跳转的指令一定会跳转.
2. 有条件的指令, 需要按照指令的要求, 在译码级增加用于比较的电路.

跳转的目的地址
1. J型指令(J和JAL)直接取低位的offset即可.
2. R型指令(JR), 需要用到rs字段的值.
3. I型指令BNE和BEQ, 按照指令集定义实现即可.

TIPS: 这里的实现是不是需要一个MUX?

### 测试代码
```
	.set noat
   	.set noreorder
   	.globl main
   	.text
main:
   lui 	$at, 0x1        # (PC = 0x00)	$at($1) = 0x10000
   j 	L2              # (PC = 0x04) 	jump to L2(addr = 0x14)
   nop			# (PC = 0x08) 	delayslot instrution
   
L3:
   jal 	L4              # (PC = 0x0C) 	jump tp L4(addr = 0x24) $ra($31) = 0x14
   lui 	$at, 0x3        # (PC = 0x10) 	delayslot instrution, $at = 0x30000

L2:
   la 	$v0, L3         # (PC = 0x14) 	$v0($2) = L3's addr
   jr 	$v0             # (PC = 0x1C) 	jump tO L3(addr = 0x0c)
   lui 	$at, 0x2        # (PC = 0x20) 	delayslot instrution, $at = 0x20000   

L4:
   bne 	$at, $v0, L5    # (PC = 0x24) 	branch to L5(addr = 0x30)
   lui 	$at, 0x4        # (PC = 0x28) 	delayslot instrution, $at = 0x40000

L6:
   lui 	$at, 0xA        # (PC = 0x2C) 	$at = 0xA0000 the cpu cannot run here

L5:
   lui 	$at, 0x5        # (PC = 0x30) 	$at = 0x50000
   lui 	$v0, 0x6	# (PC = 0x34) 	$v0 = 0x60000
   beq 	$at, $v0, L6    # (PC = 0x38) 	not branch
   nop			# (PC = 0x3C) 	delayslot instrution
  
loop:
   j 	loop		# (PC = 0x40)
   nop			# (PC = 0x44) 	delayslot instrution
```

### 修改im.sv里的代码
把原来用于测试数据相关的指令注释掉，将第二个test case(simple jump test)取消注释。

### 有正确波形吗
没有。建议使用一种模拟器，QTspim或者MARZ，研究一下如何使用，然后让模拟器单步执行测试代码，看一下自己的CPU的行为和模拟器的是否一致。
