<?php $__env->startSection('title', 'My Profile - Univent'); ?>

<?php $__env->startSection('content'); ?>
    <div class="min-h-screen bg-slate-50/50 pt-28 pb-20 px-4">
        <div class="max-w-4xl mx-auto">

            <div class="absolute -top-24 -left-24 w-96 h-96 bg-red-100 rounded-full blur-3xl opacity-80 -z-10"></div>
            <div class="absolute top-1/2 -right-24 w-80 h-80 bg-pink-100 rounded-full blur-3xl opacity-60 -z-10"></div>


            
            <div class="bg-white rounded-[2.5rem] border border-slate-100 shadow-xl shadow-slate-200/50 overflow-hidden">
                <div class="flex flex-col md:flex-row">

                    
                    <div
                        class="md:w-1/3 p-8 md:p-12 border-b md:border-b-0 md:border-r border-slate-50 flex flex-col items-center text-center">
                        <div class="relative group mb-6">
                            <div
                                class="absolute inset-0 bg-gradient-to-tr from-red-500 to-pink-500 rounded-full blur-xl opacity-20 group-hover:opacity-40 transition-opacity">
                            </div>

                            <img src="<?php echo e($user->avatar ? (strlen($user->avatar) > 200 ? 'data:image/jpeg;base64,' . $user->avatar : asset('storage/' . $user->avatar)) : asset('images/default-avatar.svg')); ?>"
                                class="relative w-40 h-40 rounded-full object-cover border-4 border-white shadow-lg mx-auto"
                                alt="Profile Photo">
                        </div>

                        <h3 class="text-2xl font-extrabold text-slate-900 mb-1"><?php echo e($user->name); ?></h3>
                        <p class="text-sm font-bold text-red-500 uppercase tracking-widest">
                            <?php if(\Livewire\Mechanisms\ExtendBlade\ExtendBlade::isRenderingLivewireComponent()): ?><!--[if BLOCK]><![endif]--><?php endif; ?><?php if($user->hasRole('admin')): ?>
                                ADMINISTRATOR
                            <?php elseif($user->hasRole('eo')): ?>
                                EVENT ORGANIZER
                            <?php else: ?>
                                USER
                            <?php endif; ?><?php if(\Livewire\Mechanisms\ExtendBlade\ExtendBlade::isRenderingLivewireComponent()): ?><!--[if ENDBLOCK]><![endif]--><?php endif; ?>
                        </p>

                        
                        <div class="grid grid-cols-2 gap-4 mt-8 w-full">
                            <div class="bg-slate-50 p-3 rounded-2xl">
                                <span class="block text-xl font-black text-slate-900">0</span>
                                <span class="text-[10px] font-bold text-slate-400 uppercase">Events</span>
                            </div>
                            <div class="bg-slate-50 p-3 rounded-2xl">
                                <span class="block text-xl font-black text-slate-900">0</span>
                                <span class="text-[10px] font-bold text-slate-400 uppercase">History</span>
                            </div>
                        </div>
                    </div>

                    
                    <div class="md:w-2/3 p-8 md:p-12 flex flex-col justify-between">
                        <div>
                            <div class="flex items-center justify-between mb-8">
                                <h2 class="text-2xl font-extrabold text-slate-900 italic">Personal Information</h2>
                                <div class="h-1 w-12 bg-gradient-to-r from-red-500 to-pink-500 rounded-full"></div>
                            </div>

                            <div class="space-y-6">
                                
                                <div class="flex items-start gap-4 group">
                                    <div
                                        class="p-3 bg-red-50 rounded-2xl text-red-500 group-hover:bg-red-500 group-hover:text-white transition-all">
                                        <?php if (isset($component)) { $__componentOriginal643fe1b47aec0b76658e1a0200b34b2c = $component; } ?>
<?php if (isset($attributes)) { $__attributesOriginal643fe1b47aec0b76658e1a0200b34b2c = $attributes; } ?>
<?php $component = BladeUI\Icons\Components\Svg::resolve([] + (isset($attributes) && $attributes instanceof Illuminate\View\ComponentAttributeBag ? $attributes->all() : [])); ?>
<?php $component->withName('heroicon-o-envelope'); ?>
<?php if ($component->shouldRender()): ?>
<?php $__env->startComponent($component->resolveView(), $component->data()); ?>
<?php if (isset($attributes) && $attributes instanceof Illuminate\View\ComponentAttributeBag): ?>
<?php $attributes = $attributes->except(\BladeUI\Icons\Components\Svg::ignoredParameterNames()); ?>
<?php endif; ?>
<?php $component->withAttributes(['class' => 'w-5 h-5']); ?>
<?php \Livewire\Features\SupportCompiledWireKeys\SupportCompiledWireKeys::processComponentKey($component); ?>

<?php echo $__env->renderComponent(); ?>
<?php endif; ?>
<?php if (isset($__attributesOriginal643fe1b47aec0b76658e1a0200b34b2c)): ?>
<?php $attributes = $__attributesOriginal643fe1b47aec0b76658e1a0200b34b2c; ?>
<?php unset($__attributesOriginal643fe1b47aec0b76658e1a0200b34b2c); ?>
<?php endif; ?>
<?php if (isset($__componentOriginal643fe1b47aec0b76658e1a0200b34b2c)): ?>
<?php $component = $__componentOriginal643fe1b47aec0b76658e1a0200b34b2c; ?>
<?php unset($__componentOriginal643fe1b47aec0b76658e1a0200b34b2c); ?>
<?php endif; ?>
                                    </div>
                                    <div>
                                        <span
                                            class="block text-xs font-bold text-slate-400 uppercase tracking-tighter">Email
                                            Address</span>
                                        <p class="text-slate-700 font-semibold"><?php echo e($user->email); ?></p>
                                    </div>
                                </div>

                                
                                <div class="flex items-start gap-4 group">
                                    <div
                                        class="p-3 bg-pink-50 rounded-2xl text-pink-500 group-hover:bg-pink-500 group-hover:text-white transition-all">
                                        <?php if (isset($component)) { $__componentOriginal643fe1b47aec0b76658e1a0200b34b2c = $component; } ?>
<?php if (isset($attributes)) { $__attributesOriginal643fe1b47aec0b76658e1a0200b34b2c = $attributes; } ?>
<?php $component = BladeUI\Icons\Components\Svg::resolve([] + (isset($attributes) && $attributes instanceof Illuminate\View\ComponentAttributeBag ? $attributes->all() : [])); ?>
<?php $component->withName('heroicon-o-calendar-days'); ?>
<?php if ($component->shouldRender()): ?>
<?php $__env->startComponent($component->resolveView(), $component->data()); ?>
<?php if (isset($attributes) && $attributes instanceof Illuminate\View\ComponentAttributeBag): ?>
<?php $attributes = $attributes->except(\BladeUI\Icons\Components\Svg::ignoredParameterNames()); ?>
<?php endif; ?>
<?php $component->withAttributes(['class' => 'w-5 h-5']); ?>
<?php \Livewire\Features\SupportCompiledWireKeys\SupportCompiledWireKeys::processComponentKey($component); ?>

<?php echo $__env->renderComponent(); ?>
<?php endif; ?>
<?php if (isset($__attributesOriginal643fe1b47aec0b76658e1a0200b34b2c)): ?>
<?php $attributes = $__attributesOriginal643fe1b47aec0b76658e1a0200b34b2c; ?>
<?php unset($__attributesOriginal643fe1b47aec0b76658e1a0200b34b2c); ?>
<?php endif; ?>
<?php if (isset($__componentOriginal643fe1b47aec0b76658e1a0200b34b2c)): ?>
<?php $component = $__componentOriginal643fe1b47aec0b76658e1a0200b34b2c; ?>
<?php unset($__componentOriginal643fe1b47aec0b76658e1a0200b34b2c); ?>
<?php endif; ?>
                                    </div>
                                    <div>
                                        <span
                                            class="block text-xs font-bold text-slate-400 uppercase tracking-tighter">Birthday</span>
                                        <p class="text-slate-700 font-semibold">
                                            <?php echo e($user->profile?->birthday ? \Carbon\Carbon::parse($user->profile->birthday)->format('d F Y') : 'Not set yet'); ?>

                                        </p>
                                    </div>
                                </div>

                                
                                <div class="flex items-start gap-4 group">
                                    <div
                                        class="p-3 bg-slate-100 rounded-2xl text-slate-500 group-hover:bg-slate-900 group-hover:text-white transition-all">
                                        <?php if (isset($component)) { $__componentOriginal643fe1b47aec0b76658e1a0200b34b2c = $component; } ?>
<?php if (isset($attributes)) { $__attributesOriginal643fe1b47aec0b76658e1a0200b34b2c = $attributes; } ?>
<?php $component = BladeUI\Icons\Components\Svg::resolve([] + (isset($attributes) && $attributes instanceof Illuminate\View\ComponentAttributeBag ? $attributes->all() : [])); ?>
<?php $component->withName('heroicon-o-phone'); ?>
<?php if ($component->shouldRender()): ?>
<?php $__env->startComponent($component->resolveView(), $component->data()); ?>
<?php if (isset($attributes) && $attributes instanceof Illuminate\View\ComponentAttributeBag): ?>
<?php $attributes = $attributes->except(\BladeUI\Icons\Components\Svg::ignoredParameterNames()); ?>
<?php endif; ?>
<?php $component->withAttributes(['class' => 'w-5 h-5']); ?>
<?php \Livewire\Features\SupportCompiledWireKeys\SupportCompiledWireKeys::processComponentKey($component); ?>

<?php echo $__env->renderComponent(); ?>
<?php endif; ?>
<?php if (isset($__attributesOriginal643fe1b47aec0b76658e1a0200b34b2c)): ?>
<?php $attributes = $__attributesOriginal643fe1b47aec0b76658e1a0200b34b2c; ?>
<?php unset($__attributesOriginal643fe1b47aec0b76658e1a0200b34b2c); ?>
<?php endif; ?>
<?php if (isset($__componentOriginal643fe1b47aec0b76658e1a0200b34b2c)): ?>
<?php $component = $__componentOriginal643fe1b47aec0b76658e1a0200b34b2c; ?>
<?php unset($__componentOriginal643fe1b47aec0b76658e1a0200b34b2c); ?>
<?php endif; ?>
                                    </div>
                                    <div>
                                        <span
                                            class="block text-xs font-bold text-slate-400 uppercase tracking-tighter">Phone
                                            Number</span>
                                        <p class="text-slate-700 font-semibold">
                                            <?php echo e($user->profile?->phone ?? 'Not set yet'); ?></p>
                                    </div>
                                </div>
                            </div>
                        </div>

                        
                        <div class="mt-12 pt-8 border-t border-slate-50 flex flex-wrap items-center gap-4">
                            

                            <a href="<?php echo e(route('profile.edit')); ?>"
                                class="flex-1 text-center px-8 py-3.5 bg-gradient-to-r from-red-600 to-pink-500 text-white font-bold rounded-2xl shadow-lg shadow-pink-500/25 hover:scale-105 transition transform active:scale-95 text-sm">
                                Edit Profile
                            </a>

                            <form action="<?php echo e(route('logout')); ?>" method="POST" class="w-full md:w-auto">
                                <?php echo csrf_field(); ?>
                                <button type="submit"
                                    class="w-full flex items-center justify-center gap-2 px-6 py-3.5 bg-white border border-red-200 text-red-500 font-bold rounded-2xl hover:bg-red-50 transition-all text-sm">
                                    <?php if (isset($component)) { $__componentOriginal643fe1b47aec0b76658e1a0200b34b2c = $component; } ?>
<?php if (isset($attributes)) { $__attributesOriginal643fe1b47aec0b76658e1a0200b34b2c = $attributes; } ?>
<?php $component = BladeUI\Icons\Components\Svg::resolve([] + (isset($attributes) && $attributes instanceof Illuminate\View\ComponentAttributeBag ? $attributes->all() : [])); ?>
<?php $component->withName('heroicon-o-arrow-left-on-rectangle'); ?>
<?php if ($component->shouldRender()): ?>
<?php $__env->startComponent($component->resolveView(), $component->data()); ?>
<?php if (isset($attributes) && $attributes instanceof Illuminate\View\ComponentAttributeBag): ?>
<?php $attributes = $attributes->except(\BladeUI\Icons\Components\Svg::ignoredParameterNames()); ?>
<?php endif; ?>
<?php $component->withAttributes(['class' => 'w-4 h-4']); ?>
<?php \Livewire\Features\SupportCompiledWireKeys\SupportCompiledWireKeys::processComponentKey($component); ?>

<?php echo $__env->renderComponent(); ?>
<?php endif; ?>
<?php if (isset($__attributesOriginal643fe1b47aec0b76658e1a0200b34b2c)): ?>
<?php $attributes = $__attributesOriginal643fe1b47aec0b76658e1a0200b34b2c; ?>
<?php unset($__attributesOriginal643fe1b47aec0b76658e1a0200b34b2c); ?>
<?php endif; ?>
<?php if (isset($__componentOriginal643fe1b47aec0b76658e1a0200b34b2c)): ?>
<?php $component = $__componentOriginal643fe1b47aec0b76658e1a0200b34b2c; ?>
<?php unset($__componentOriginal643fe1b47aec0b76658e1a0200b34b2c); ?>
<?php endif; ?>
                                    Log Out
                                </button>
                            </form>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
<?php $__env->stopSection(); ?>

<?php echo $__env->make('layouts.app', array_diff_key(get_defined_vars(), ['__data' => 1, '__path' => 1]))->render(); ?><?php /**PATH R:\ABp tubes\univent2.0\ABP\univent 2.0\resources\views/profile.blade.php ENDPATH**/ ?>