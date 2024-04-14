// Obtener el campo de entrada de búsqueda
const searchInput = document.getElementById('search-input');

// Agregar un evento de escucha al campo de entrada
searchInput.addEventListener('input', function() {
    const searchTerm = this.value.toLowerCase(); // Obtener el término de búsqueda en minúsculas
    const estudiantes = document.querySelectorAll('.main__estudiantes-list li'); // Obtener todos los elementos de la lista de estudiantes

    // Iterar sobre cada estudiante y mostrar u ocultar según el término de búsqueda
    estudiantes.forEach(function(estudiante) {
        const nombre = estudiante.textContent.toLowerCase();

        if (nombre.includes(searchTerm)) {
            estudiante.style.display = 'block'; // Mostrar el estudiante si el nombre coincide con el término de búsqueda
        } else {
            estudiante.style.display = 'none'; // Ocultar el estudiante si el nombre no coincide con el término de búsqueda
        }
    });
});

// Obtenemos una referencia al botón "Nuevo" y al formulario de matrícula
const nuevoEstudianteBtn = document.getElementById('nuevo_estudiante');
const formularioMatricula = document.getElementById('formulario-matricula');

// Agregamos un event listener al botón "Nuevo"
nuevoEstudianteBtn.addEventListener('click', function() {
    // Cambiamos la visibilidad del formulario
    formularioMatricula.style.display = 'flex'; // Mostramos el formulario
});

// Obtenemos una referencia al botón "Cancelar"
const cancelarEstudianteBtn = document.getElementById('cerrar_formulario');

// Agregamos un event listener al botón "Cancelar"
cancelarEstudianteBtn.addEventListener('click', function() {
    // Limpiar todos los campos de entrada
    const campos = document.querySelectorAll('input[type="text"], input[type="date"]');
    campos.forEach(function(campo) {
        campo.value = ''; // Establecer el valor del campo en una cadena vacía
    });
    // Cambiamos la visibilidad del formulario para ocultarlo
    formularioMatricula.style.display = 'none'; // Ocultamos el formulario
});

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

//Eliminar
document.addEventListener('DOMContentLoaded', function() {
    // Obtener una referencia a todos los botones "Eliminar" mediante su clase
    const eliminarEstudianteBtns = document.querySelectorAll('.eliminar-estudiante');

    // Obtener una referencia al contenedor del formulario de confirmación de eliminación
    const confirmarEliminarContainer = document.getElementById('confirmar-eliminar');

    // Obtener una referencia al botón "Cancelar" del formulario de confirmación de eliminación
    const cancelarEliminarBtn = document.getElementById('cancelar-eliminar');

    // Agregar un event listener a cada botón "Eliminar"
    eliminarEstudianteBtns.forEach(function(btn) {
        btn.addEventListener('click', function(event) {
            // Prevenir el comportamiento predeterminado del botón (enviar el formulario)
            event.preventDefault();

            // Obtener el ID del estudiante que se eliminará
            const estudianteId = this.dataset.estudianteId;

            // Mostrar el formulario de confirmación de eliminación
            confirmarEliminarContainer.style.display = 'block';

            // Agregar un event listener al botón "Cancelar" del formulario de confirmación de eliminación
            cancelarEliminarBtn.addEventListener('click', function() {
                // Ocultar el formulario de confirmación de eliminación
                confirmarEliminarContainer.style.display = 'none';
            });

            // Agregar un event listener al formulario de confirmación de eliminación
            const confirmarEliminarForm = document.getElementById('form-confirmar-eliminar');
            confirmarEliminarForm.addEventListener('submit', function() {
                // Enviar el formulario para eliminar el estudiante
                confirmarEliminarForm.action = `/delete_estudiante/${estudianteId}/`;
            });
        });
    });
});


