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
ifneq ($(strip $(CC_DEPS)),)
-include $(CC_DEPS)
endif
ifneq ($(strip $(CPP_DEPS)),)
-include $(CPP_DEPS)
endif
ifneq ($(strip $(CXX_DEPS)),)
-include $(CXX_DEPS)
endif
ifneq ($(strip $(C_UPPER_DEPS)),)
-include $(C_UPPER_DEPS)
endif
ifneq ($(strip $(S_UPPER_DEPS)),)
-include $(S_UPPER_DEPS)
endif
endif

-include ../makefile.defs

# Add inputs and outputs from these tool invocations to the build variables 
ELFSIZE += \
v01_initial_sw.elf.size \

ELFCHECK += \
v01_initial_sw.elf.elfcheck \


# All Target
all: v01_initial_sw.elf secondary-outputs

# Tool invocations
v01_initial_sw.elf: $(OBJS) ../src/lscript.ld $(USER_OBJS)
	@echo Building target: $@
	@echo Invoking: MicroBlaze g++ linker
	mb-gcc -Wl,-T -Wl,../src/lscript.ld -L../../v01_initial_bsp/microblaze_0/lib -mxl-barrel-shift -mxl-pattern-compare -mcpu=v7.30.b -mno-xl-soft-mul -o"v01_initial_sw.elf" $(OBJS) $(USER_OBJS) $(LIBS)
	@echo Finished building target: $@
	@echo ' '

v01_initial_sw.elf.size: v01_initial_sw.elf
	@echo Invoking: MicroBlaze Print Size
	mb-size v01_initial_sw.elf  |tee "v01_initial_sw.elf.size"
	@echo Finished building: $@
	@echo ' '

v01_initial_sw.elf.elfcheck: v01_initial_sw.elf
	@echo Invoking: Xilinx ELF Check
	elfcheck v01_initial_sw.elf -hw ../../v01_initial_hw/system.xml -pe microblaze_0  |tee "v01_initial_sw.elf.elfcheck"
	@echo Finished building: $@
	@echo ' '

# Other Targets
clean:
	-$(RM) $(OBJS)$(C_DEPS)$(CC_DEPS)$(CPP_DEPS)$(EXECUTABLES)$(ELFSIZE)$(CXX_DEPS)$(C_UPPER_DEPS)$(ELFCHECK)$(S_UPPER_DEPS) v01_initial_sw.elf
	-@echo ' '

secondary-outputs: $(ELFSIZE) $(ELFCHECK)

.PHONY: all clean dependents
.SECONDARY:

-include ../makefile.targets
