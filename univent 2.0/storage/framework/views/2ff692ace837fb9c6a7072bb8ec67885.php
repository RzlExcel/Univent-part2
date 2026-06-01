<!DOCTYPE html>
<html lang="en" class="h-full bg-slate-50">
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title><?php echo $__env->yieldContent('title'); ?> - Univent</title>
    <link rel="icon" href="<?php echo e(asset('images/univent-logo3.png')); ?>" type="image/png">
    
    
    <?php echo app('Illuminate\Foundation\Vite')(['resources/css/app.css', 'resources/js/app.js']); ?>
    
    
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800&display=swap" rel="stylesheet">
    
    <style>
        body { font-family: 'Plus Jakarta Sans', sans-serif; }
        [x-cloak] { display: none !important; }
    </style>
</head>
<body class="h-full antialiased">
    <div class="min-h-screen flex flex-col justify-center py-12 sm:px-6 lg:px-8 bg-gradient-to-br from-blue-50 to-indigo-50">
        <div class="sm:mx-auto sm:w-full sm:max-w-md text-center">
            <a href="/">
                <img src="<?php echo e(asset('images/univent-logo.png')); ?>" alt="Univent Logo" class="mx-auto h-12 w-auto">
            </a>
            <h2 class="mt-6 text-3xl font-extrabold text-gray-900 tracking-tight">
                <?php echo $__env->yieldContent('header'); ?>
            </h2>
            <p class="mt-2 text-sm text-gray-600">
                <?php echo $__env->yieldContent('subtitle'); ?>
            </p>
        </div>

        <div class="mt-8 sm:mx-auto sm:w-full sm:max-w-md">
            <div class="bg-white py-8 px-4 shadow-xl shadow-blue-900/5 sm:rounded-2xl sm:px-10 border border-white">
                <?php echo $__env->yieldContent('content'); ?>
            </div>
        </div>
    </div>

    <?php echo $__env->make('partials.sweetalert', array_diff_key(get_defined_vars(), ['__data' => 1, '__path' => 1]))->render(); ?>
    <?php echo $__env->yieldPushContent('scripts'); ?>
</body>
</html><?php /**PATH R:\ABp tubes\univent2.0\ABP\univent 2.0\resources\views/layouts/auth.blade.php ENDPATH**/ ?>