################################################################################
# Automatically-generated file. Do not edit!
################################################################################

# Add inputs and outputs from these tool invocations to the build variables 
C_SRCS += \
../src/ivk_camera.c \
../src/ivk_camera_menu.c \
../src/ivk_fir_2d.c \
../src/ivk_frame_buffer.c \
../src/ivk_iic_diag.c \
../src/ivk_processing_menu.c \
../src/ivk_top.c \
../src/ivk_video_resolution.c 

LD_SRCS += \
../src/lscript.ld 

OBJS += \
./src/ivk_camera.o \
./src/ivk_camera_menu.o \
./src/ivk_fir_2d.o \
./src/ivk_frame_buffer.o \
./src/ivk_iic_diag.o \
./src/ivk_processing_menu.o \
./src/ivk_top.o \
./src/ivk_video_resolution.o 

C_DEPS += \
./src/ivk_camera.d \
./src/ivk_camera_menu.d \
./src/ivk_fir_2d.d \
./src/ivk_frame_buffer.d \
./src/ivk_iic_diag.d \
./src/ivk_processing_menu.d \
./src/ivk_top.d \
./src/ivk_video_resolution.d 


# Each subdirectory must supply rules for building sources it contributes
src/%.o: ../src/%.c
	@echo Building file: $<
	@echo Invoking: MicroBlaze g++ compiler
	mb-gcc -Wall -O0 -g3 -c -fmessage-length=0 -I../../v01_initial_bsp/microblaze_0/include -mxl-barrel-shift -mxl-pattern-compare -mcpu=v7.30.b -mno-xl-soft-mul -MMD -MP -MF"$(@:%.o=%.d)" -MT"$(@:%.o=%.d)" -o"$@" "$<"
	@echo Finished building: $<
	@echo ' '


