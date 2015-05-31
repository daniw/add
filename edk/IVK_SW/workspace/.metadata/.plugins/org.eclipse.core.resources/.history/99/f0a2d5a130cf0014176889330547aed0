################################################################################
# Automatically-generated file. Do not edit!
################################################################################

-include ../makefile.init

RM := rm -rf

# All of the sources participating in the build are defined here
-include sources.mk
-include subdir.mk
-include src/subdir.mk
-include objects.mk

ifneq ($(MAKECMDGOALS),clean)
ifneq ($(strip $(C_DEPS)),)
-include $(C_DEPS)
endif
ifneq ($(strip $(S_UPPER_DEPS)),)
-include $(S_UPPER_DEPS)
endif
endif

-include ../makefile.defs

# Add inputs and outputs from these tool invocations to the build variables 
ELFSIZE += \
t01_hello_sw.elf.size \

ELFCHECK += \
t01_hello_sw.elf.elfcheck \


# All Target
all: t01_hello_sw.elf secondary-outputs

# Tool invocations
t01_hello_sw.elf: $(OBJS) ../src/lscript.ld $(USER_OBJS)
	@echo Building target: $@
	@echo Invoking: MicroBlaze gcc linker
	mb-gcc -Wl,-T -Wl,../src/lscript.ld -L../../t01_hello_bsp/microblaze_0/lib -mxl-barrel-shift -mxl-pattern-compare -mcpu=v8.20.a -mno-xl-soft-mul -o"t01_hello_sw.elf" $(OBJS) $(USER_OBJS) $(LIBS)
	@echo Finished building target: $@
	@echo ' '

t01_hello_sw.elf.size: t01_hello_sw.elf
	@echo Invoking: MicroBlaze Print Size
	mb-size t01_hello_sw.elf  |tee "t01_hello_sw.elf.size"
	@echo Finished building: $@
	@echo ' '

t01_hello_sw.elf.elfcheck: t01_hello_sw.elf
	@echo Invoking: Xilinx ELF Check
	elfcheck t01_hello_sw.elf -hw ../../t01_hello_hw/system.xml -pe microblaze_0  |tee "t01_hello_sw.elf.elfcheck"
	@echo Finished building: $@
	@echo ' '

# Other Targets
clean:
	-$(RM) $(OBJS)$(C_DEPS)$(EXECUTABLES)$(ELFSIZE)$(ELFCHECK)$(S_UPPER_DEPS) t01_hello_sw.elf
	-@echo ' '

secondary-outputs: $(ELFSIZE) $(ELFCHECK)

.PHONY: all clean dependents
.SECONDARY:

-include ../makefile.targets
