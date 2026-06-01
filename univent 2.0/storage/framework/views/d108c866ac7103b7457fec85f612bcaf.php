<script src="//cdn.jsdelivr.net/npm/sweetalert2@11"></script>
<script>
    <?php if(session('success')): ?>
        Swal.fire({
            icon: 'success',
            title: 'Berhasil!',
            text: '<?php echo e(session('success')); ?>',
            timer: 3000,
            showConfirmButton: false
        });
    <?php endif; ?>

    <?php if(session('error')): ?>
        Swal.fire({
            icon: 'error',
            title: 'Oops...',
            text: '<?php echo e(session('error')); ?>'
        });
    <?php endif; ?>

    <?php if($errors->any()): ?>
        var errorList = '<ul style="text-align: left; list-style-position: inside;">';
        <?php $__currentLoopData = $errors->all(); $__env->addLoop($__currentLoopData); foreach($__currentLoopData as $error): $__env->incrementLoopIndices(); $loop = $__env->getLastLoop(); ?>
            errorList += '<li><?php echo e($error); ?></li>';
        <?php endforeach; $__env->popLoop(); $loop = $__env->getLastLoop(); ?>
        errorList += '</ul>';

        Swal.fire({
            icon: 'error',
            title: 'Validasi Gagal',
            html: errorList,
        });
    <?php endif; ?>
</script>


<?php /**PATH R:\ABp tubes\univent2.0\ABP\univent 2.0\resources\views/partials/sweetalert.blade.php ENDPATH**/ ?>