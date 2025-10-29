<template>
  <div class="module-container">
    <!-- Header -->
    <div class="module-header">
      <div class="module-title-section">
        <i class="fas fa-percent module-icon"></i>
        <div>
          <h1 class="module-title">ABC de Recargos</h1>
          <p class="module-subtitle">Gestión de porcentajes de recargos mensuales</p>
        </div>
      </div>
      <div class="module-actions">
        <button class="btn-help" @click="mostrarAyuda = true">
          <i class="fas fa-question-circle"></i>
          Ayuda
        </button>
      </div>
    </div>

    <!-- Búsqueda de Período -->
    <div class="card">
      <div class="card-header">
        <i class="fas fa-calendar-alt"></i>
        Búsqueda de Período
      </div>
      <div class="card-body">
        <div class="form-grid-three">
          <div class="form-group">
            <label class="form-label required">Año</label>
            <input
              type="number"
              v-model.number="busqueda.axo"
              class="form-input"
              :min="1994"
              :max="currentYear"
              placeholder="Año"
            />
          </div>
          <div class="form-group">
            <label class="form-label required">Mes</label>
            <select v-model.number="busqueda.mes" class="form-input">
              <option :value="0">-- Seleccione --</option>
              <option v-for="mes in meses" :key="mes.valor" :value="mes.valor">
                {{ mes.nombre }}
              </option>
            </select>
          </div>
          <div class="form-group align-end">
            <button
              class="btn-municipal-primary"
              @click="verificarPeriodo"
              :disabled="!busquedaValida"
            >
              <i class="fas fa-search"></i>
              Verificar
            </button>
          </div>
        </div>
      </div>
    </div>

    <!-- Formulario de Recargo -->
    <div v-if="mostrarFormulario" class="card mt-3">
      <div class="card-header">
        <i class="fas fa-edit"></i>
        {{ modoEdicion ? 'Modificar Recargo' : 'Registrar Nuevo Recargo' }}
      </div>
      <div class="card-body">
        <div class="alert-info mb-3">
          <i class="fas fa-info-circle"></i>
          <span>
            {{ modoEdicion ? 'Modifique el porcentaje mensual' : 'Ingrese el nuevo porcentaje mensual' }}
          </span>
        </div>

        <div class="form-grid-two">
          <div class="form-group">
            <label class="form-label required">Porcentaje Mensual (%)</label>
            <input
              ref="porcentajeInput"
              type="number"
              v-model.number="formulario.porcentaje_parcial"
              class="form-input"
              step="0.01"
              min="0.01"
              max="100"
              placeholder="0.00"
            />
            <small class="form-help">Porcentaje que se aplica en este mes específico</small>
          </div>
          <div class="form-group">
            <label class="form-label">Porcentaje Acumulado (%)</label>
            <input
              type="number"
              v-model.number="formulario.porcentaje_global"
              class="form-input"
              disabled
              placeholder="0.00"
            />
            <small class="form-help">Se calcula automáticamente después de guardar</small>
          </div>
        </div>

        <div class="summary-box mt-3">
          <div class="summary-item">
            <span class="summary-label">Período:</span>
            <span class="summary-value">
              {{ nombreMes(busqueda.mes) }} {{ busqueda.axo }}
            </span>
          </div>
          <div class="summary-item">
            <span class="summary-label">Operación:</span>
            <span class="summary-value" :class="modoEdicion ? 'warning' : 'primary'">
              {{ modoEdicion ? 'Modificación' : 'Alta' }}
            </span>
          </div>
        </div>

        <div class="form-actions">
          <button
            class="btn-municipal-secondary"
            @click="cancelarFormulario"
          >
            <i class="fas fa-times"></i>
            Cancelar
          </button>
          <button
            class="btn-municipal-primary"
            @click="guardarRecargo"
            :disabled="!formularioValido"
          >
            <i class="fas fa-save"></i>
            {{ modoEdicion ? 'Modificar' : 'Guardar' }}
          </button>
        </div>
      </div>
    </div>

    <!-- Historial de Recargos del Mes -->
    <div v-if="recargosDelMes.length > 0" class="card mt-3">
      <div class="card-header">
        <i class="fas fa-history"></i>
        Historial de {{ nombreMes(busqueda.mes) }}
      </div>
      <div class="card-body">
        <div class="table-container">
          <table class="data-table">
            <thead>
              <tr>
                <th>Año</th>
                <th>Mes</th>
                <th>% Mensual</th>
                <th>% Acumulado</th>
                <th>Usuario</th>
                <th>Fecha Modificación</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="recargo in recargosDelMes" :key="`${recargo.axo}-${recargo.mes}`">
                <td>{{ recargo.axo }}</td>
                <td>{{ nombreMes(recargo.mes) }}</td>
                <td class="text-bold">{{ formatPorcentaje(recargo.porcentaje_parcial) }}</td>
                <td class="text-bold primary">{{ formatPorcentaje(recargo.porcentaje_global) }}</td>
                <td>{{ recargo.usuario || 'N/A' }}</td>
                <td>{{ formatDate(recargo.fecha_mov) }}</td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
    </div>

    <!-- Modal de Ayuda -->
    <DocumentationModal
      v-if="mostrarAyuda"
      title="Ayuda - ABC de Recargos"
      @close="mostrarAyuda = false"
    >
      <div class="help-content">
        <section class="help-section">
          <h3><i class="fas fa-info-circle"></i> Descripción</h3>
          <p>
            Este módulo permite gestionar los porcentajes de recargos mensuales que se aplican
            a los adeudos de cementerios. Los recargos se calculan de forma acumulativa.
          </p>
        </section>

        <section class="help-section">
          <h3><i class="fas fa-calculator"></i> Porcentajes</h3>
          <ul>
            <li><strong>Porcentaje Mensual:</strong> Es el porcentaje que se aplica específicamente en ese mes</li>
            <li><strong>Porcentaje Acumulado:</strong> Es la suma de todos los porcentajes mensuales desde 1994</li>
            <li>El porcentaje acumulado tiene un límite máximo de 100%</li>
          </ul>
        </section>

        <section class="help-section">
          <h3><i class="fas fa-list-ol"></i> Proceso</h3>
          <ol>
            <li>Seleccione el año y mes que desea configurar</li>
            <li>Presione "Verificar" para buscar si existe un registro</li>
            <li>Si existe: el sistema carga los datos y permite modificar</li>
            <li>Si no existe: el sistema permite dar de alta un nuevo porcentaje</li>
            <li>Ingrese o modifique el porcentaje mensual</li>
            <li>Presione "Guardar" o "Modificar"</li>
            <li>El sistema calcula automáticamente los porcentajes acumulados</li>
          </ol>
        </section>

        <section class="help-section">
          <h3><i class="fas fa-cogs"></i> Cálculo Automático</h3>
          <p>
            Al guardar o modificar un recargo, el sistema automáticamente:
          </p>
          <ul>
            <li>Recalcula los porcentajes acumulados desde 1994</li>
            <li>Actualiza los porcentajes de años futuros para el mismo mes</li>
            <li>Aplica el límite de 100% cuando se alcanza</li>
          </ul>
        </section>

        <section class="help-section">
          <h3><i class="fas fa-table"></i> Historial</h3>
          <p>
            La tabla muestra todos los años que tienen configurado un porcentaje para el mes seleccionado,
            ordenados del más reciente al más antiguo.
          </p>
        </section>
      </div>
    </DocumentationModal>
  </div>
</template>

<script setup>
import { ref, computed, nextTick } from 'vue'
import { useApi } from '@/composables/useApi'
import { useToast } from '@/composables/useToast'
import DocumentationModal from '@/components/common/DocumentationModal.vue'

const { callProcedure } = useApi()
const { showSuccess, showError } = useToast()

// Estado
const mostrarAyuda = ref(false)
const mostrarFormulario = ref(false)
const modoEdicion = ref(false)
const porcentajeInput = ref(null)

// Año actual
const currentYear = new Date().getFullYear()
const currentMonth = new Date().getMonth() + 1

// Búsqueda
const busqueda = ref({
  axo: currentYear,
  mes: currentMonth
})

// Formulario
const formulario = ref({
  porcentaje_parcial: 1,
  porcentaje_global: 0
})

// Recargos del mes
const recargosDelMes = ref([])

// Meses del año
const meses = [
  { valor: 1, nombre: 'Enero' },
  { valor: 2, nombre: 'Febrero' },
  { valor: 3, nombre: 'Marzo' },
  { valor: 4, nombre: 'Abril' },
  { valor: 5, nombre: 'Mayo' },
  { valor: 6, nombre: 'Junio' },
  { valor: 7, nombre: 'Julio' },
  { valor: 8, nombre: 'Agosto' },
  { valor: 9, nombre: 'Septiembre' },
  { valor: 10, nombre: 'Octubre' },
  { valor: 11, nombre: 'Noviembre' },
  { valor: 12, nombre: 'Diciembre' }
]

// Validaciones
const busquedaValida = computed(() => {
  return busqueda.value.axo >= 1994 &&
         busqueda.value.axo <= currentYear &&
         busqueda.value.mes >= 1 &&
         busqueda.value.mes <= 12
})

const formularioValido = computed(() => {
  return formulario.value.porcentaje_parcial > 0 &&
         formulario.value.porcentaje_parcial <= 100
})

// Verificar si existe el recargo para el período
const verificarPeriodo = async () => {
  if (!busquedaValida.value) {
    showError('Por favor ingrese un año y mes válidos')
    return
  }

  try {
    // Buscar recargo específico
    const result = await callProcedure('SP_CEM_BUSCAR_RECARGO', {
      p_axo: busqueda.value.axo,
      p_mes: busqueda.value.mes
    })

    // Cargar historial del mes
    await cargarRecargosDelMes()

    if (result.resultado === 'S') {
      // Existe - modo modificación
      modoEdicion.value = true
      formulario.value.porcentaje_parcial = result.porcentaje_parcial
      formulario.value.porcentaje_global = result.porcentaje_global
      mostrarFormulario.value = true

      await nextTick()
      if (porcentajeInput.value) {
        porcentajeInput.value.focus()
      }
    } else if (result.resultado === 'N') {
      // No existe - modo alta
      modoEdicion.value = false
      formulario.value.porcentaje_parcial = 1
      formulario.value.porcentaje_global = 0
      mostrarFormulario.value = true

      await nextTick()
      if (porcentajeInput.value) {
        porcentajeInput.value.focus()
      }
    } else {
      showError(result.mensaje || 'Error al verificar período')
    }
  } catch (error) {
    console.error('Error al verificar período:', error)
    showError('Error al verificar el período')
  }
}

// Cargar recargos del mes seleccionado
const cargarRecargosDelMes = async () => {
  try {
    const result = await callProcedure('SP_CEM_LISTAR_RECARGOS_MES', {
      p_mes: busqueda.value.mes
    })

    recargosDelMes.value = result.data || []
  } catch (error) {
    console.error('Error al cargar recargos:', error)
    recargosDelMes.value = []
  }
}

// Guardar recargo
const guardarRecargo = async () => {
  if (!formularioValido.value) {
    showError('Por favor complete todos los campos requeridos')
    return
  }

  try {
    // Guardar o modificar recargo
    const resultRegistro = await callProcedure('SP_CEM_REGISTRAR_RECARGO', {
      p_operacion: modoEdicion.value ? 2 : 1,
      p_axo: busqueda.value.axo,
      p_mes: busqueda.value.mes,
      p_porcentaje: formulario.value.porcentaje_parcial,
      p_usuario: 1 // TODO: Obtener de sesión
    })

    if (resultRegistro.resultado === 'S') {
      // Calcular acumulados
      const resultAcumulado = await callProcedure('SP_CEM_CALCULAR_ACUMULADO_RECARGOS', {
        p_axo: busqueda.value.axo,
        p_mes: busqueda.value.mes
      })

      if (resultAcumulado.resultado === 'S') {
        showSuccess(
          modoEdicion.value
            ? 'Recargo modificado y acumulados actualizados'
            : 'Recargo registrado y acumulados calculados'
        )

        // Recargar historial
        await cargarRecargosDelMes()

        // Ocultar formulario
        cancelarFormulario()
      } else {
        showError('Recargo guardado pero error al calcular acumulados')
      }
    } else {
      showError(resultRegistro.mensaje || 'Error al guardar recargo')
    }
  } catch (error) {
    console.error('Error al guardar recargo:', error)
    showError('Error al guardar el recargo')
  }
}

// Cancelar formulario
const cancelarFormulario = () => {
  mostrarFormulario.value = false
  formulario.value.porcentaje_parcial = 1
  formulario.value.porcentaje_global = 0
  modoEdicion.value = false
}

// Obtener nombre del mes
const nombreMes = (mes) => {
  const mesObj = meses.find(m => m.valor === mes)
  return mesObj ? mesObj.nombre : ''
}

// Formatear porcentaje
const formatPorcentaje = (value) => {
  if (value == null) return '0.00%'
  return `${Number(value).toFixed(2)}%`
}

// Formatear fecha
const formatDate = (date) => {
  if (!date) return ''
  return new Date(date).toLocaleDateString('es-MX')
}
</script>

<style scoped>
.align-end {
  align-self: flex-end;
}

.text-bold {
  font-weight: 600;
}

.primary {
  color: var(--color-primary);
}

.warning {
  color: var(--color-warning);
}

.mt-3 {
  margin-top: 1rem;
}

.mb-3 {
  margin-bottom: 1rem;
}

.form-help {
  display: block;
  margin-top: 0.25rem;
  font-size: 0.875rem;
  color: var(--color-text-secondary);
}
</style>
