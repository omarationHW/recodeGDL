# Casos de Uso - Rep_Tipos_Emp

**Categoría:** Form

## Caso de Uso 1: Consulta de Tipos de Empresas ordenado por Control

**Descripción:** El usuario desea visualizar el catálogo de Tipos de Empresas ordenado por número de control.

**Precondiciones:**
El usuario tiene acceso al sistema y permisos para consultar catálogos.

**Pasos a seguir:**
1. El usuario navega a la página 'Reporte Tipos de Empresas'.
2. Selecciona 'Control' en el selector de orden.
3. Hace clic en 'Vista Previa'.
4. El sistema muestra la tabla ordenada por número de control.

**Resultado esperado:**
La tabla muestra todos los tipos de empresa ordenados ascendentemente por el campo 'ctrol_emp'.

**Datos de prueba:**
Tipos de empresa: (1, 'PRIVADA', 'Empresa Privada'), (2, 'PUBLICA', 'Empresa Pública'), (3, 'MIXTA', 'Empresa Mixta')

---

## Caso de Uso 2: Consulta de Tipos de Empresas ordenado por Tipo

**Descripción:** El usuario desea visualizar el catálogo de Tipos de Empresas ordenado por tipo.

**Precondiciones:**
El usuario tiene acceso al sistema.

**Pasos a seguir:**
1. El usuario accede a la página de reporte.
2. Selecciona 'Tipo' en el selector de orden.
3. Hace clic en 'Vista Previa'.

**Resultado esperado:**
La tabla muestra los tipos de empresa ordenados alfabéticamente por 'tipo_empresa'.

**Datos de prueba:**
Tipos de empresa: (1, 'PRIVADA', ...), (2, 'MIXTA', ...), (3, 'PUBLICA', ...)

---

## Caso de Uso 3: Consulta de Tipos de Empresas ordenado por Descripción

**Descripción:** El usuario desea visualizar el catálogo de Tipos de Empresas ordenado por descripción.

**Precondiciones:**
El usuario está autenticado.

**Pasos a seguir:**
1. El usuario abre la página de reporte.
2. Selecciona 'Descripción' en el selector.
3. Hace clic en 'Vista Previa'.

**Resultado esperado:**
La tabla muestra los tipos de empresa ordenados alfabéticamente por 'descripcion'.

**Datos de prueba:**
Tipos de empresa: (1, 'PRIVADA', 'Empresa Privada'), (2, 'PUBLICA', 'Empresa Pública'), (3, 'MIXTA', 'Empresa Mixta')

---

