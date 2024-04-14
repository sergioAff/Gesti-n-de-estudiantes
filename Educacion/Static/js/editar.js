// Obtenemos una referencia al botón "Cancelar"
const cancelarEstudianteBtn = document.getElementById('cerrar_formulario');

// Agregamos un event listener al botón "Cancelar"
cancelarEstudianteBtn.addEventListener('click', function() {
    // Redirigir a la página matricula.html utilizando la sintaxis de plantillas de Django
    window.location.href = matriculaUrl;
});

//AQuiiiiiiiiiiiiiiii
document.addEventListener('DOMContentLoaded', function() {
    const form = document.getElementById('form-matricula');
    const enviarBtn = document.getElementById('enviar_formulario');

    // Agregar eventos de escucha a los campos del formulario
    const campos = form.querySelectorAll('input, textarea');
    campos.forEach(function(campo) {
        campo.addEventListener('keyup', validarCampo);
        campo.addEventListener('change', validarCampo);
    });

    function validarCampo() {
        // Validar cada campo del formulario
        let formularioValido = true;
        campos.forEach(function(campo) {
            if (campo.required && campo.value.trim() === '') {
                formularioValido = false;
                mostrarError(campo, 'Este campo es obligatorio.');
            } else {
                ocultarError(campo);
            }
        });

        // Habilitar o deshabilitar el botón de enviar
        enviarBtn.disabled = !formularioValido;

        // Agregar clase de animación al botón de enviar
        if (formularioValido && !enviarBtn.classList.contains('animacion')) {
            enviarBtn.classList.add('animacion');
        } else if (!formularioValido) {
            enviarBtn.classList.remove('animacion');
        }
    }

    function mostrarError(campo, mensaje) {
        // Mostrar mensaje de error debajo del campo
        const errorDiv = campo.nextElementSibling;
        if (errorDiv && errorDiv.classList.contains('error-message')) {
            errorDiv.textContent = mensaje;
            errorDiv.style.display = 'block';
        } else {
            const nuevoErrorDiv = document.createElement('div');
            nuevoErrorDiv.className = 'error-message';
            nuevoErrorDiv.textContent = mensaje;
            campo.parentNode.insertBefore(nuevoErrorDiv, campo.nextSibling);
        }
    }

    function ocultarError(campo) {
        // Ocultar mensaje de error si existe
        const errorDiv = campo.nextElementSibling;
        if (errorDiv && errorDiv.classList.contains('error-message')) {
            errorDiv.style.display = 'none';
        }
    }
});

//Fecha
document.addEventListener('DOMContentLoaded', function() {
    const form = document.getElementById('form-matricula');
    const enviarBtn = document.getElementById('enviar_formulario');

    // Obtener el campo de fecha de nacimiento
    const fechaInput = document.getElementById('fecha_nacimiento');
    // Agregar evento de cambio al campo de fecha de nacimiento
    fechaInput.addEventListener('change', validarFechaNacimiento);

    // Agregar eventos de escucha a los campos del formulario
    const campos = form.querySelectorAll('input, textarea');
    campos.forEach(function(campo) {
        campo.addEventListener('keyup', validarCampo);
    });

    function validarCampo() {
        // Validar cada campo del formulario
        let formularioValido = true;
        campos.forEach(function(campo) {
            if (campo.required && campo.value.trim() === '') {
                formularioValido = false;
            }
        });

        // Habilitar o deshabilitar el botón de enviar
        if (formularioValido && validarFechaNacimiento()) {
            enviarBtn.style.display = 'inline-block';
        } else {
            enviarBtn.style.display = 'none';
        }
    }

    function validarFechaNacimiento() {
        // Obtener la fecha de nacimiento del campo
        const fechaNacimiento = new Date(fechaInput.value);
        // Calcular la fecha hace 18 años
        const hace18Anos = new Date();
        hace18Anos.setFullYear(hace18Anos.getFullYear() - 18);

        // Verificar si la fecha de nacimiento es válida (hace al menos 18 años)
        if (fechaNacimiento > hace18Anos) {
            // Mostrar un mensaje de error
            const errorDiv = document.getElementById('fecha_validada');
            errorDiv.textContent = 'Debes tener al menos 18 años para matricularte.';
            errorDiv.style.color = 'red';
            return false;
        } else {
            // Limpiar el mensaje de error si la fecha es válida
            const errorDiv = document.getElementById('fecha_validada');
            errorDiv.textContent = '';
            return true;
        }
    }
});
