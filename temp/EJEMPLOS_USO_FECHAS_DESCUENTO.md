# EJEMPLOS DE USO: Stored Procedures - Fechas de Descuento

Este documento contiene ejemplos prácticos de uso de los Stored Procedures para el Mantenimiento de Fechas de Descuento en diferentes contextos.

---

## 1. USO DIRECTO EN SQL (psql, DBeaver, pgAdmin)

### 1.1. Consultas Básicas

```sql
-- Listar todas las fechas de descuento
SELECT * FROM fechas_descuento_get_all();

-- Listar solo meses específicos
SELECT * FROM fechas_descuento_get_all() WHERE mes IN (1, 2, 3);

-- Buscar un mes específico
SELECT * FROM fechas_descuento_get_all() WHERE mes = 6;

-- Ordenar por fecha de modificación
SELECT * FROM fechas_descuento_get_all() ORDER BY fecha_alta DESC;
```

### 1.2. Actualizaciones

```sql
-- Actualizar enero (mes 1)
SELECT * FROM fechas_descuento_update(
    1,                      -- mes
    '2025-01-05'::DATE,    -- fecha_descuento
    '2025-01-10'::DATE,    -- fecha_recargos
    1                       -- id_usuario
);

-- Actualizar diciembre (mes 12)
SELECT * FROM fechas_descuento_update(
    12,
    '2025-12-05'::DATE,
    '2025-12-10'::DATE,
    1
);

-- Verificar el cambio
SELECT * FROM fechas_descuento_get_all() WHERE mes = 1;
```

### 1.3. Inicialización Completa (12 Meses)

```sql
-- Crear todos los meses con fechas estándar (día 5 descuento, día 10 recargos)
DO $$
DECLARE
    i INTEGER;
BEGIN
    FOR i IN 1..12 LOOP
        PERFORM fechas_descuento_update(
            i::SMALLINT,
            ('2025-' || LPAD(i::TEXT, 2, '0') || '-05')::DATE,
            ('2025-' || LPAD(i::TEXT, 2, '0') || '-10')::DATE,
            1
        );
    END LOOP;
END $$;

-- Verificar que se crearon los 12 meses
SELECT COUNT(*) as total FROM fechas_descuento_get_all();
-- Esperado: 12

-- Ver todos
SELECT * FROM fechas_descuento_get_all();
```

---

## 2. USO DESDE LARAVEL/PHP

### 2.1. Controller Básico

```php
<?php

namespace App\Http\Controllers\Api;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class FechasDescuentoController extends Controller
{
    /**
     * Listar todas las fechas de descuento
     */
    public function index()
    {
        try {
            $fechas = DB::select("SELECT * FROM fechas_descuento_get_all()");

            return response()->json([
                'success' => true,
                'data' => $fechas
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Error al obtener fechas: ' . $e->getMessage()
            ], 500);
        }
    }

    /**
     * Obtener fecha de un mes específico
     */
    public function show($mes)
    {
        try {
            $fecha = DB::select(
                "SELECT * FROM fechas_descuento_get_all() WHERE mes = ?",
                [$mes]
            );

            if (empty($fecha)) {
                return response()->json([
                    'success' => false,
                    'message' => 'Mes no encontrado'
                ], 404);
            }

            return response()->json([
                'success' => true,
                'data' => $fecha[0]
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Error al obtener fecha: ' . $e->getMessage()
            ], 500);
        }
    }

    /**
     * Actualizar fecha de descuento
     */
    public function update(Request $request)
    {
        $validated = $request->validate([
            'mes' => 'required|integer|min:1|max:12',
            'fecha_descuento' => 'required|date',
            'fecha_recargos' => 'required|date|after_or_equal:fecha_descuento',
            'id_usuario' => 'required|integer'
        ]);

        try {
            $result = DB::select(
                "SELECT * FROM fechas_descuento_update(?, ?::DATE, ?::DATE, ?)",
                [
                    $validated['mes'],
                    $validated['fecha_descuento'],
                    $validated['fecha_recargos'],
                    $validated['id_usuario']
                ]
            );

            return response()->json([
                'success' => $result[0]->success,
                'message' => $result[0]->message
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Error al actualizar fecha: ' . $e->getMessage()
            ], 500);
        }
    }

    /**
     * Actualizar múltiples meses
     */
    public function updateBatch(Request $request)
    {
        $validated = $request->validate([
            'fechas' => 'required|array',
            'fechas.*.mes' => 'required|integer|min:1|max:12',
            'fechas.*.fecha_descuento' => 'required|date',
            'fechas.*.fecha_recargos' => 'required|date',
            'id_usuario' => 'required|integer'
        ]);

        $resultados = [];
        $errores = [];

        DB::beginTransaction();

        try {
            foreach ($validated['fechas'] as $fecha) {
                $result = DB::select(
                    "SELECT * FROM fechas_descuento_update(?, ?::DATE, ?::DATE, ?)",
                    [
                        $fecha['mes'],
                        $fecha['fecha_descuento'],
                        $fecha['fecha_recargos'],
                        $validated['id_usuario']
                    ]
                );

                if (!$result[0]->success) {
                    $errores[] = [
                        'mes' => $fecha['mes'],
                        'error' => $result[0]->message
                    ];
                } else {
                    $resultados[] = [
                        'mes' => $fecha['mes'],
                        'message' => $result[0]->message
                    ];
                }
            }

            if (!empty($errores)) {
                DB::rollBack();
                return response()->json([
                    'success' => false,
                    'message' => 'Errores en la actualización',
                    'errores' => $errores
                ], 422);
            }

            DB::commit();

            return response()->json([
                'success' => true,
                'message' => 'Fechas actualizadas correctamente',
                'resultados' => $resultados
            ]);
        } catch (\Exception $e) {
            DB::rollBack();

            return response()->json([
                'success' => false,
                'message' => 'Error en actualización masiva: ' . $e->getMessage()
            ], 500);
        }
    }
}
```

### 2.2. Rutas API (api.php)

```php
use App\Http\Controllers\Api\FechasDescuentoController;

Route::prefix('mercados')->group(function () {
    Route::prefix('fechas-descuento')->group(function () {
        Route::get('/', [FechasDescuentoController::class, 'index']);
        Route::get('/{mes}', [FechasDescuentoController::class, 'show']);
        Route::post('/update', [FechasDescuentoController::class, 'update']);
        Route::post('/update-batch', [FechasDescuentoController::class, 'updateBatch']);
    });
});
```

### 2.3. Uso en Blade/Livewire

```php
// En un componente Livewire
public function mount()
{
    $this->fechas = DB::select("SELECT * FROM fechas_descuento_get_all()");
}

public function actualizarFecha($mes)
{
    $result = DB::select(
        "SELECT * FROM fechas_descuento_update(?, ?::DATE, ?::DATE, ?)",
        [
            $mes,
            $this->fechas[$mes]['fecha_descuento'],
            $this->fechas[$mes]['fecha_recargos'],
            auth()->id()
        ]
    );

    if ($result[0]->success) {
        session()->flash('message', 'Fecha actualizada correctamente');
    }
}
```

---

## 3. USO DESDE VUE.JS / JAVASCRIPT

### 3.1. API Service

```javascript
// services/fechasDescuentoService.js
import apiService from './apiService';

export default {
    /**
     * Obtener todas las fechas de descuento
     */
    async getAll() {
        try {
            const response = await apiService.call(
                'FechasDescuento',
                'list'
            );
            return response.data;
        } catch (error) {
            console.error('Error al obtener fechas:', error);
            throw error;
        }
    },

    /**
     * Obtener fecha de un mes específico
     */
    async getByMes(mes) {
        try {
            const response = await apiService.get(
                `/mercados/fechas-descuento/${mes}`
            );
            return response.data;
        } catch (error) {
            console.error(`Error al obtener mes ${mes}:`, error);
            throw error;
        }
    },

    /**
     * Actualizar fecha de descuento
     */
    async update(mes, fechaDescuento, fechaRecargos, idUsuario) {
        try {
            const response = await apiService.call(
                'FechasDescuento',
                'update',
                {
                    mes,
                    fecha_descuento: fechaDescuento,
                    fecha_recargos: fechaRecargos,
                    id_usuario: idUsuario
                }
            );
            return response.data;
        } catch (error) {
            console.error('Error al actualizar fecha:', error);
            throw error;
        }
    },

    /**
     * Actualizar múltiples fechas
     */
    async updateBatch(fechas, idUsuario) {
        try {
            const response = await apiService.post(
                '/mercados/fechas-descuento/update-batch',
                {
                    fechas,
                    id_usuario: idUsuario
                }
            );
            return response.data;
        } catch (error) {
            console.error('Error en actualización masiva:', error);
            throw error;
        }
    }
};
```

### 3.2. Componente Vue - Listado

```vue
<!-- components/FechasDescuentoList.vue -->
<template>
  <div class="fechas-descuento-container">
    <h2>Fechas de Descuento por Mes</h2>

    <table class="table">
      <thead>
        <tr>
          <th>Mes</th>
          <th>Nombre</th>
          <th>Fecha Descuento</th>
          <th>Fecha Recargos</th>
          <th>Última Modificación</th>
          <th>Usuario</th>
          <th>Acciones</th>
        </tr>
      </thead>
      <tbody>
        <tr v-for="fecha in fechas" :key="fecha.mes">
          <td>{{ fecha.mes }}</td>
          <td>{{ getNombreMes(fecha.mes) }}</td>
          <td>{{ formatDate(fecha.fecha_descuento) }}</td>
          <td>{{ formatDate(fecha.fecha_recargos) }}</td>
          <td>{{ formatDateTime(fecha.fecha_alta) }}</td>
          <td>{{ fecha.usuario }}</td>
          <td>
            <button @click="editarFecha(fecha)" class="btn btn-sm btn-primary">
              Editar
            </button>
          </td>
        </tr>
      </tbody>
    </table>

    <!-- Modal de edición -->
    <EditarFechaModal
      v-if="showModal"
      :fecha="fechaSeleccionada"
      @close="showModal = false"
      @updated="cargarFechas"
    />
  </div>
</template>

<script>
import fechasDescuentoService from '@/services/fechasDescuentoService';
import EditarFechaModal from './EditarFechaModal.vue';

export default {
  name: 'FechasDescuentoList',
  components: {
    EditarFechaModal
  },
  data() {
    return {
      fechas: [],
      loading: false,
      showModal: false,
      fechaSeleccionada: null,
      meses: [
        'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
        'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
      ]
    };
  },
  mounted() {
    this.cargarFechas();
  },
  methods: {
    async cargarFechas() {
      this.loading = true;
      try {
        const response = await fechasDescuentoService.getAll();
        this.fechas = response.data || [];
      } catch (error) {
        this.$toast.error('Error al cargar fechas de descuento');
      } finally {
        this.loading = false;
      }
    },

    getNombreMes(mes) {
      return this.meses[mes - 1] || '';
    },

    formatDate(date) {
      if (!date) return '';
      return new Date(date).toLocaleDateString('es-MX');
    },

    formatDateTime(datetime) {
      if (!datetime) return '';
      return new Date(datetime).toLocaleString('es-MX');
    },

    editarFecha(fecha) {
      this.fechaSeleccionada = { ...fecha };
      this.showModal = true;
    }
  }
};
</script>
```

### 3.3. Componente Vue - Edición

```vue
<!-- components/EditarFechaModal.vue -->
<template>
  <div class="modal-overlay" @click.self="$emit('close')">
    <div class="modal-content">
      <h3>Editar Fecha de Descuento - {{ getNombreMes(form.mes) }}</h3>

      <form @submit.prevent="guardar">
        <div class="form-group">
          <label>Mes:</label>
          <input
            type="number"
            v-model.number="form.mes"
            min="1"
            max="12"
            disabled
            class="form-control"
          />
        </div>

        <div class="form-group">
          <label>Fecha de Descuento:</label>
          <input
            type="date"
            v-model="form.fecha_descuento"
            required
            class="form-control"
          />
        </div>

        <div class="form-group">
          <label>Fecha de Recargos:</label>
          <input
            type="date"
            v-model="form.fecha_recargos"
            required
            class="form-control"
          />
        </div>

        <div class="form-actions">
          <button type="button" @click="$emit('close')" class="btn btn-secondary">
            Cancelar
          </button>
          <button type="submit" :disabled="loading" class="btn btn-primary">
            {{ loading ? 'Guardando...' : 'Guardar' }}
          </button>
        </div>
      </form>
    </div>
  </div>
</template>

<script>
import fechasDescuentoService from '@/services/fechasDescuentoService';
import { mapGetters } from 'vuex';

export default {
  name: 'EditarFechaModal',
  props: {
    fecha: {
      type: Object,
      required: true
    }
  },
  data() {
    return {
      form: {
        mes: this.fecha.mes,
        fecha_descuento: this.fecha.fecha_descuento,
        fecha_recargos: this.fecha.fecha_recargos
      },
      loading: false,
      meses: [
        'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
        'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
      ]
    };
  },
  computed: {
    ...mapGetters('auth', ['userId'])
  },
  methods: {
    getNombreMes(mes) {
      return this.meses[mes - 1] || '';
    },

    async guardar() {
      this.loading = true;

      try {
        const response = await fechasDescuentoService.update(
          this.form.mes,
          this.form.fecha_descuento,
          this.form.fecha_recargos,
          this.userId
        );

        if (response.success) {
          this.$toast.success(response.message);
          this.$emit('updated');
          this.$emit('close');
        } else {
          this.$toast.error(response.message);
        }
      } catch (error) {
        this.$toast.error('Error al actualizar fecha de descuento');
      } finally {
        this.loading = false;
      }
    }
  }
};
</script>

<style scoped>
.modal-overlay {
  position: fixed;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  background: rgba(0, 0, 0, 0.5);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 1000;
}

.modal-content {
  background: white;
  padding: 2rem;
  border-radius: 8px;
  max-width: 500px;
  width: 90%;
}

.form-group {
  margin-bottom: 1rem;
}

.form-group label {
  display: block;
  margin-bottom: 0.5rem;
  font-weight: 600;
}

.form-actions {
  display: flex;
  justify-content: flex-end;
  gap: 1rem;
  margin-top: 1.5rem;
}
</style>
```

---

## 4. CASOS DE USO ESPECÍFICOS

### 4.1. Actualización Anual (Inicio de Año)

```sql
-- Actualizar todas las fechas para el año 2026
DO $$
DECLARE
    i INTEGER;
BEGIN
    FOR i IN 1..12 LOOP
        PERFORM fechas_descuento_update(
            i::SMALLINT,
            ('2026-' || LPAD(i::TEXT, 2, '0') || '-05')::DATE,
            ('2026-' || LPAD(i::TEXT, 2, '0') || '-10')::DATE,
            1
        );
    END LOOP;
END $$;

-- Verificar
SELECT
    mes,
    fecha_descuento,
    fecha_recargos,
    EXTRACT(YEAR FROM fecha_descuento) as año
FROM fechas_descuento_get_all()
ORDER BY mes;
```

### 4.2. Consultas de Auditoría

```sql
-- Ver últimas modificaciones
SELECT
    mes,
    fecha_descuento,
    fecha_recargos,
    fecha_alta,
    usuario
FROM fechas_descuento_get_all()
ORDER BY fecha_alta DESC
LIMIT 10;

-- Ver quién modificó cada mes
SELECT
    mes,
    usuario,
    fecha_alta
FROM fechas_descuento_get_all()
ORDER BY mes;
```

### 4.3. Validación de Fechas

```sql
-- Verificar que fecha_recargos sea después de fecha_descuento
SELECT
    mes,
    fecha_descuento,
    fecha_recargos,
    CASE
        WHEN fecha_recargos > fecha_descuento THEN 'OK'
        ELSE 'ERROR: Fecha recargos debe ser posterior'
    END as validacion
FROM fechas_descuento_get_all()
ORDER BY mes;
```

### 4.4. Exportar a Excel (desde Laravel)

```php
use Maatwebsite\Excel\Facades\Excel;
use App\Exports\FechasDescuentoExport;

public function exportar()
{
    return Excel::download(new FechasDescuentoExport, 'fechas_descuento.xlsx');
}

// App\Exports\FechasDescuentoExport.php
class FechasDescuentoExport implements FromCollection
{
    public function collection()
    {
        return collect(DB::select("SELECT * FROM fechas_descuento_get_all()"));
    }
}
```

---

## 5. INTEGRACIÓN CON OTROS MÓDULOS

### 5.1. Obtener Fecha de Descuento del Mes Actual

```sql
-- En otros SPs, obtener la fecha de descuento del mes actual
CREATE OR REPLACE FUNCTION get_fecha_descuento_actual()
RETURNS DATE AS $$
DECLARE
    v_fecha DATE;
    v_mes SMALLINT;
BEGIN
    v_mes := EXTRACT(MONTH FROM CURRENT_DATE)::SMALLINT;

    SELECT fecha_descuento INTO v_fecha
    FROM fechas_descuento_get_all()
    WHERE mes = v_mes;

    RETURN v_fecha;
END;
$$ LANGUAGE plpgsql;

-- Uso
SELECT get_fecha_descuento_actual();
```

### 5.2. Validar si Aplica Descuento

```sql
CREATE OR REPLACE FUNCTION aplica_descuento(p_fecha_pago DATE)
RETURNS BOOLEAN AS $$
DECLARE
    v_fecha_descuento DATE;
    v_mes SMALLINT;
BEGIN
    v_mes := EXTRACT(MONTH FROM p_fecha_pago)::SMALLINT;

    SELECT fecha_descuento INTO v_fecha_descuento
    FROM fechas_descuento_get_all()
    WHERE mes = v_mes;

    RETURN p_fecha_pago <= v_fecha_descuento;
END;
$$ LANGUAGE plpgsql;

-- Uso
SELECT aplica_descuento('2025-01-04'::DATE); -- true
SELECT aplica_descuento('2025-01-06'::DATE); -- false (si fecha_descuento es 05)
```

### 5.3. Calcular Recargo

```sql
CREATE OR REPLACE FUNCTION aplica_recargo(p_fecha_pago DATE)
RETURNS BOOLEAN AS $$
DECLARE
    v_fecha_recargos DATE;
    v_mes SMALLINT;
BEGIN
    v_mes := EXTRACT(MONTH FROM p_fecha_pago)::SMALLINT;

    SELECT fecha_recargos INTO v_fecha_recargos
    FROM fechas_descuento_get_all()
    WHERE mes = v_mes;

    RETURN p_fecha_pago > v_fecha_recargos;
END;
$$ LANGUAGE plpgsql;

-- Uso
SELECT aplica_recargo('2025-01-11'::DATE); -- true (si fecha_recargos es 10)
```

---

## 6. TIPS Y MEJORES PRÁCTICAS

### 6.1. Caché en Frontend

```javascript
// Cachear las fechas por 1 hora
const CACHE_KEY = 'fechas_descuento';
const CACHE_DURATION = 60 * 60 * 1000; // 1 hora

async function getFechasConCache() {
    const cached = localStorage.getItem(CACHE_KEY);

    if (cached) {
        const { data, timestamp } = JSON.parse(cached);
        const now = Date.now();

        if (now - timestamp < CACHE_DURATION) {
            return data;
        }
    }

    const fechas = await fechasDescuentoService.getAll();

    localStorage.setItem(CACHE_KEY, JSON.stringify({
        data: fechas,
        timestamp: Date.now()
    }));

    return fechas;
}
```

### 6.2. Validación de Fechas en Frontend

```javascript
function validarFechas(fechaDescuento, fechaRecargos) {
    const desc = new Date(fechaDescuento);
    const rec = new Date(fechaRecargos);

    if (rec <= desc) {
        return {
            valid: false,
            message: 'La fecha de recargos debe ser posterior a la de descuento'
        };
    }

    return { valid: true };
}
```

### 6.3. Notificaciones de Cambio

```php
// En el Controller, enviar notificación después de actualizar
use App\Notifications\FechaDescuentoActualizada;

public function update(Request $request)
{
    // ... actualización ...

    // Notificar a administradores
    $admins = User::where('role', 'admin')->get();
    Notification::send($admins, new FechaDescuentoActualizada([
        'mes' => $validated['mes'],
        'fecha_descuento' => $validated['fecha_descuento'],
        'usuario' => auth()->user()->name
    ]));

    return response()->json([...]);
}
```

---

**Fin de Ejemplos**

_Este documento proporciona ejemplos completos para integrar los SPs de Fechas de Descuento en diferentes partes del sistema RecodeGDL - Mercados._
