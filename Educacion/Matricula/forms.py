from django.forms import ModelForm
from .models import Estudiantes

class MyForm(ModelForm):
    class Meta:
        model=Estudiantes
        fields=['nombre','fecha_nacimiento', 'direccion','contacto','datos_academicos']   # Campos que se van a mostrar en el formulario
