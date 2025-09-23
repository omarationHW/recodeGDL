# Documentación de Módulos

## Integración de Módulos

Cada proyecto Delphi migrado se integra como un módulo independiente en el sistema Harweb.

### Estructura de Módulo

```
modules/[nombre-modulo]/
├── backend-laravel/          # API Laravel del módulo
│   ├── app/
│   ├── routes/
│   └── config/
├── frontend-vue/            # Interfaz Vue del módulo  
│   ├── src/
│   ├── components/
│   └── views/
├── docs/                    # Documentación del módulo
│   ├── README.md
│   ├── use-cases/
│   └── test-cases/
└── database/               # Scripts SQL específicos
```

### Registro Automático

Los módulos se registran automáticamente al:

1. Detectar la carpeta en `/modules/`
2. Cargar configuración del módulo
3. Registrar rutas y componentes
4. Actualizar navegación del sidebar

### Navegación

El sidebar se actualiza dinámicamente basado en:

- Módulos disponibles en `/modules/`
- Configuración de cada módulo
- Permisos del usuario actual

### API Unificada

Cada módulo mantiene:

- API independiente con patrón eRequest/eResponse
- Endpoint unificado `/api/execute`
- Stored procedures PostgreSQL
- Documentación automática de operaciones