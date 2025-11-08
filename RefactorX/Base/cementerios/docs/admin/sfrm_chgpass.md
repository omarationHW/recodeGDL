# sfrm_chgpass - Cambio de Contraseña

## Propósito Administrativo
Módulo de seguridad que permite a los usuarios cambiar su contraseña de acceso al sistema de forma autónoma y segura.

## Funcionalidad Principal
Permite al usuario modificar su contraseña validando la contraseña actual y estableciendo una nueva que cumpla políticas de seguridad.

## Proceso de Negocio

### ¿Qué hace?
- Solicita contraseña actual
- Valida contraseña actual
- Permite capturar nueva contraseña
- Confirma nueva contraseña
- Actualiza contraseña en base de datos

### ¿Para qué sirve?
- Seguridad de acceso
- Cambio periódico de contraseñas
- Recuperación de acceso comprometido
- Cumplimiento de políticas de seguridad

### ¿Cómo lo hace?
1. Usuario ingresa contraseña actual
2. Sistema valida contra base de datos
3. Usuario captura nueva contraseña dos veces
4. Sistema valida que coincidan
5. Actualiza contraseña del usuario

## Datos y Tablas
**ta_usuarios** - Actualiza campo de contraseña (encriptado)

## Usuarios del Sistema
Todos los usuarios del sistema
