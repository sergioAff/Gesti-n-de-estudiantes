from django.shortcuts import render, redirect
from .models import Estudiantes
from .forms import MyForm


def index(request):
    return render(request, 'index.html')


def matricula(request):
    estudiantes = Estudiantes.objects.all()

    # Obtener el parámetro de orden de la URL
    orden = request.GET.get('orden')

    # Ordenar la lista de estudiantes según el parámetro recibido
    if orden == 'id_asc':
        estudiantes = estudiantes.order_by('estudiante_id')
    elif orden == 'id_desc':
        estudiantes = estudiantes.order_by('-estudiante_id')

    return render(request, 'matricula.html', {'estudiantes': estudiantes})


def delete_estudiante(request, estudiante_id):
    if request.method == 'POST':
        estudiante = Estudiantes.objects.get(pk=estudiante_id)
        estudiante.delete()
        return redirect('matricula')

def edit_estudiante(request, estudiante_id):
    # Obtener el estudiante específico que se desea editar
    estudiante = Estudiantes.objects.get(pk=estudiante_id)
    
    if request.method == 'POST':
        # Si el formulario ha sido enviado, procesar los datos del formulario
        form = MyForm(request.POST, instance=estudiante)
        if form.is_valid():
            form.save()  # Guardar los cambios en la base de datos
            return redirect('matricula')  # Redirigir a la página principal después de guardar los cambios
    else:
        # Si la solicitud es GET, cargar el formulario prellenado con los datos del estudiante
        form = MyForm(instance=estudiante)
    
        # Renderizar el template de edición con el formulario prellenado
        return render(request, 'editar_estudiante.html', {'form': form, 'estudiante':estudiante})

def formulario(request):
    
    if request.method == 'POST':
        form = MyForm(request.POST)
        if form.is_valid():
            form.save()
            return redirect('matricula')  # Redirigir a la página principal después de guardar los datos
        else:
            return render(request, 'matricula.html', {'form': form})

    else:
        form = MyForm()
        
    return render(request, 'matricula.html', {'form': form})



