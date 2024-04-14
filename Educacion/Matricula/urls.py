from django.urls import path
from .views import index, matricula, formulario, delete_estudiante, edit_estudiante

urlpatterns = [
    path('Escuela/', index, name='index'),
    path('Matricula/', matricula, name='matricula'),
    path('Formulario/', formulario, name='formulario'),
    path('delete_estudiante/<int:estudiante_id>/', delete_estudiante, name='delete_estudiante'),  # Aquí debes asegurarte de que la URL coincida
    path('editar_estudiante/<int:estudiante_id>/', edit_estudiante, name='editar_estudiante')
]
