# Cambio de Contraseña

## Propósito Administrativo
Permitir a los usuarios cambiar su contraseña de acceso al sistema de manera segura, conectándose directamente al servidor Unix para actualizar las credenciales y garantizar la sincronización entre el sistema y la base de datos.

## Funcionalidad Principal
Este módulo proporciona una interfaz para que los usuarios cambien su contraseña, conectándose mediante Telnet al servidor Unix, validando la contraseña actual, verificando que la nueva cumpla con políticas de seguridad y actualizándola en el sistema operativo.

## Proceso de Negocio

### ¿Qué hace?
Permite el cambio seguro de contraseña mediante conexión Telnet al servidor Unix, validando la contraseña actual, verificando que la nueva contraseña cumpla con requisitos de seguridad (números y letras, longitud mínima, diferencias con la actual) y actualizando las credenciales en el sistema operativo.

### ¿Para qué sirve?
- Permitir a usuarios cambiar su contraseña periódicamente
- Cumplir con políticas de seguridad informática
- Garantizar la actualización correcta en el servidor
- Validar fortaleza de contraseñas
- Prevenir contraseñas débiles o repetidas
- Mantener la seguridad del sistema

### ¿Cómo lo hace?
1. El sistema se conecta automáticamente al servidor Unix (192.168.6.50:23) vía Telnet
2. El usuario ingresa su contraseña actual
3. El sistema valida que coincida con la contraseña registrada
4. Se conecta al servidor con las credenciales actuales
5. El usuario ingresa la nueva contraseña
6. El sistema valida que la nueva contraseña cumpla con:
   - Longitud entre 2 y 8 caracteres
   - Contener al menos un número
   - Contener al menos una letra minúscula
   - Ser diferente a la contraseña actual
   - Tener al menos 6 caracteres de longitud
   - Los primeros 3 caracteres deben ser diferentes a los actuales
   - Solo permite números y letras (sin caracteres especiales)
7. El usuario confirma la nueva contraseña
8. El sistema valida que la confirmación coincida
9. Ejecuta el comando `passwd` en el servidor Unix
10. Envía la contraseña actual para autenticación
11. Envía la nueva contraseña dos veces
12. Verifica que el cambio fue exitoso
13. Muestra mensaje de confirmación y cierra la conexión

### ¿Qué necesita para funcionar?
- Conexión de red al servidor Unix (192.168.6.50)
- Servicio Telnet activo en puerto 23
- Usuario válido en el sistema
- Contraseña actual correcta
- Permisos para cambiar contraseña en el servidor
- Componente TnCnx configurado

## Datos y Tablas

### Tabla Principal
No utiliza tablas directamente. La contraseña se actualiza en el sistema operativo Unix.

### Tablas Relacionadas
- **Acceso al sistema**: Utiliza el nombre de usuario de la conexión a base de datos
- **Validación**: Compara con la contraseña actual del formulario de acceso

### Stored Procedures (SP)
No utiliza stored procedures. La actualización es directamente en el sistema operativo.

### Tablas que Afecta
No modifica tablas de base de datos. Actualiza el archivo de contraseñas del sistema operativo Unix.

## Impacto y Repercusiones

### Repercusiones Operativas
- Permite a usuarios gestionar su seguridad
- Reduce carga administrativa de soporte técnico
- Garantiza actualización inmediata de credenciales
- Mantiene la seguridad del sistema

### Repercusiones Financieras
- No tiene impacto financiero directo

### Repercusiones Administrativas
- Cumple con políticas de seguridad informática
- Documenta cambios de contraseña
- Apoya auditorías de seguridad
- Previene accesos no autorizados
- Garantiza contraseñas robustas

## Validaciones y Controles
- Valida contraseña actual antes de permitir cambio
- Requiere que nueva contraseña contenga números y letras
- Valida longitud mínima de 6 caracteres
- Requiere que nueva contraseña sea diferente a la actual
- Valida que primeros 3 caracteres sean diferentes
- Requiere confirmación de nueva contraseña
- Solo permite caracteres alfanuméricos
- Valida que confirmación coincida con nueva contraseña
- Verifica éxito de la actualización en el servidor
- Maneja errores de conexión y autenticación

## Casos de Uso
1. **Usuario**: Cambia su contraseña por política de seguridad
2. **Usuario**: Actualiza contraseña comprometida
3. **Usuario**: Cambia contraseña temporal asignada
4. **Administrador**: Usuario cambia contraseña olvidada previamente restablecida

## Usuarios del Sistema
- Todos los usuarios del sistema
- Cualquier usuario con credenciales válidas
- Personal operativo y administrativo

## Relaciones con Otros Módulos
- **Acceso**: Formulario de inicio de sesión que valida las credenciales
- **ModuloDb**: Configuración de conexión a base de datos con credenciales
- **Menu**: Acceso al módulo de cambio de contraseña desde el menú principal
