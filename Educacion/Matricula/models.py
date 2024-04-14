from django.db import models

class Estudiantes(models.Model):
    estudiante_id = models.AutoField(primary_key=True)
    nombre = models.CharField(max_length=100, blank=False, null=True)
    fecha_nacimiento = models.DateField(blank=False, null=True)
    direccion = models.TextField(blank=False, null=True)
    contacto = models.CharField(max_length=20, blank=False, null=True)
    datos_academicos = models.TextField(blank=False, null=True)

    class Meta:
        db_table = 'estudiantes'
