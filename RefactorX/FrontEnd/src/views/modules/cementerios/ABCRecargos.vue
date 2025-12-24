<template>
  <div class="module-view">
    <!-- Header -->
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="percent" />
      </div>
      <div class="module-view-info">
        <h1>ABC de Recargos</h1>
        <p>Gestión de porcentajes de recargos mensuales</p>
      </div>
      <div class="button-group ms-auto">
        <button class="btn-municipal-info" @click="abrirDocumentacion">
          <font-awesome-icon icon="book" />
          Documentación
        </button>
        <button class="btn-municipal-purple" @click="abrirAyuda">
          <font-awesome-icon icon="question-circle" />
          Ayuda
        </button>
      </div>
    </div>

    <div class="module-view-content">
      <!-- Búsqueda de Período -->
      <div class="municipal-card">
        <div class="municipal-card-header">
          <h5>
            <font-awesome-icon icon="calendar-alt" />
            Búsqueda de Período
          </h5>
        </div>
        <div class="municipal-card-body">
        <div class="form-row">
          <div class="form-group">
            <label class="municipal-form-label required">Año</label>
            <input
              type="number"
              v-model.number="busqueda.axo"
              class="municipal-form-control"
              :min="1994"
              :max="currentYear"
              placeholder="Año"
            />
          </div>
          <div class="form-group">
            <label class="municipal-form-label required">Mes</label>
            <select v-model.number="busqueda.mes" class="municipal-form-control">
              <option :value="0">-- Seleccione --</option>
              <option v-for="mes in meses" :key="mes.valor" :value="mes.valor">
                {{ mes.nombre }}
              </option>
            </select>
          </div>
          <div class="form-group">
            <label class="municipal-form-label">&nbsp;</label>
            <button
              class="btn-municipal-primary"
              @click="verificarPeriodo"
              :disabled="!busquedaValida"
            >
              <font-awesome-icon icon="search" />
              Verificar
            </button>
          </div>
        </div>
        </div>
      </div>

      <!-- Formulario de Recargo -->
      <div v-if="mostrarFormulario" class="municipal-card">
        <div class="municipal-card-header">
          <h5>
            <font-awesome-icon icon="edit" />
            {{ modoEdicion ? 'Modificar Recargo' : 'Registrar Nuevo Recargo' }}
          </h5>
        </div>
        <div class="municipal-card-body">
          <div style="padding: 1rem; background: #d1ecf1; color: #0c5460; border-radius: 0.5rem; display: flex; align-items: center; gap: 0.75rem; margin-bottom: 1rem;">
            <font-awesome-icon icon="info-circle" />
          <span>
            {{ modoEdicion ? 'Modifique el porcentaje mensual' : 'Ingrese el nuevo porcentaje mensual' }}
          </span>
        </div>

        <div class="form-row">
          <div class="form-group">
            <label class="municipal-form-label required">Porcentaje Mensual (%)</label>
            <input
              ref="porcentajeInput"
              type="number"
              v-model.number="formulario.porcentaje_parcial"
              class="municipal-form-control"
              step="0.01"
              min="0.01"
              max="100"
              placeholder="0.00"
            />
            <small class="text-muted" style="display: block; margin-top: 0.25rem; font-size: 0.875rem;">Porcentaje que se aplica en este mes específico</small>
          </div>
          <div class="form-group">
            <label class="municipal-form-label">Porcentaje Acumulado (%)</label>
            <input
              type="number"
              v-model.number="formulario.porcentaje_global"
              class="municipal-form-control"
              disabled
              placeholder="0.00"
            />
            <small class="text-muted" style="display: block; margin-top: 0.25rem; font-size: 0.875rem;">Se calcula automáticamente después de guardar</small>
          </div>
        </div>

        <div style="margin-top: 1rem; padding: 1rem; background: var(--color-bg-secondary); border-radius: 0.5rem; display: flex; gap: 2rem;">
          <div style="display: flex; gap: 0.5rem;">
            <span style="font-weight: 600; color: var(--color-text-secondary);">Período:</span>
            <span style="font-weight: 700;">
              {{ nombreMes(busqueda.mes) }} {{ busqueda.axo }}
            </span>
          </div>
          <div style="display: flex; gap: 0.5rem;">
            <span style="font-weight: 600; color: var(--color-text-secondary);">Operación:</span>
            <span style="font-weight: 700;" :class="modoEdicion ? 'text-warning' : 'text-primary'">
              {{ modoEdicion ? 'Modificación' : 'Alta' }}
            </span>
          </div>
        </div>

        <div class="form-actions">
          <button
            class="btn-municipal-secondary"
            @click="cancelarFormulario"
          >
            <font-awesome-icon icon="times" />
            Cancelar
          </button>
          <button
            class="btn-municipal-primary"
            @click="guardarRecargo"
            :disabled="!formularioValido"
          >
            <font-awesome-icon icon="save" />
            {{ modoEdicion ? 'Modificar' : 'Guardar' }}
          </button>
        </div>
        </div>
      </div>

      <!-- Empty State - Sin búsqueda -->
      <div v-if="recargosDelMes.length === 0 && !hasSearched" class="empty-state">
        <div class="empty-state-icon">
          <font-awesome-icon icon="percent" size="3x" />
        </div>
        <h4>ABC de Recargos</h4>
        <p>Ingrese un año y mes para verificar o registrar recargos mensuales</p>
      </div>

      <!-- Empty State - Sin resultados -->
      <div v-else-if="recargosDelMes.length === 0 && hasSearched" class="empty-state">
        <div class="empty-state-icon">
          <font-awesome-icon icon="inbox" size="3x" />
        </div>
        <h4>Sin historial</h4>
        <p>No se encontró historial de recargos para {{ nombreMes(busqueda.mes) }}</p>
      </div>

      <!-- Historial de Recargos del Mes -->
      <div v-else-if="recargosDelMes.length > 0" class="municipal-card">
        <div class="municipal-card-header header-with-badge">
          <h5>
            <font-awesome-icon icon="history" />
            Historial de {{ nombreMes(busqueda.mes) }}
          </h5>
          <div class="header-right">
            <span class="badge-purple">
              {{ formatNumber(totalRecords) }} registros
            </span>
          </div>
        </div>
        <div class="municipal-card-body table-container">
          <div class="table-responsive">
            <table class="municipal-table">
              <thead class="municipal-table-header">
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
                <tr
                  v-for="recargo in paginatedRecargos"
                  :key="`${recargo.axo}-${recargo.mes}`"
                  @click="selectedRow = recargo"
                  :class="{ 'table-row-selected': selectedRow === recargo }"
                  class="row-hover"
                >
                  <td>{{ recargo.axo }}</td>
                  <td>{{ nombreMes(recargo.mes) }}</td>
                  <td style="font-weight: 600;">{{ formatPorcentaje(recargo.porcentaje_parcial) }}</td>
                  <td class="text-primary" style="font-weight: 600;">{{ formatPorcentaje(recargo.porcentaje_global) }}</td>
                  <td>{{ recargo.usuario || 'N/A' }}</td>
                  <td>{{ formatDate(recargo.fecha_mov) }}</td>
                </tr>
              </tbody>
            </table>
          </div>

          <!-- Controles de Paginación -->
          <div v-if="recargosDelMes.length > 0" class="pagination-controls">
            <div class="pagination-info">
              <span class="text-muted">
                Mostrando {{ ((currentPage - 1) * itemsPerPage) + 1 }}
                a {{ Math.min(currentPage * itemsPerPage, totalRecords) }}
                de {{ totalRecords }} registros
              </span>
            </div>

            <div class="pagination-size">
              <label class="municipal-form-label me-2">Registros por página:</label>
              <select
                class="municipal-form-control form-control-sm"
                :value="itemsPerPage"
                @change="changePageSize($event.target.value)"
                style="width: auto; display: inline-block;"
              >
                <option value="5">5</option>
                <option value="10">10</option>
                <option value="25">25</option>
                <option value="50">50</option>
                <option value="100">100</option>
              </select>
            </div>

            <div class="pagination-buttons">
              <button
                class="btn-municipal-secondary btn-sm"
                @click="goToPage(1)"
                :disabled="currentPage === 1"
                title="Primera página"
              >
                <font-awesome-icon icon="angle-double-left" />
              </button>

              <button
                class="btn-municipal-secondary btn-sm"
                @click="goToPage(currentPage - 1)"
                :disabled="currentPage === 1"
                title="Página anterior"
              >
                <font-awesome-icon icon="angle-left" />
              </button>

              <button
                v-for="page in visiblePages"
                :key="page"
                class="btn-sm"
                :class="page === currentPage ? 'btn-municipal-primary' : 'btn-municipal-secondary'"
                @click="goToPage(page)"
              >
                {{ page }}
              </button>

              <button
                class="btn-municipal-secondary btn-sm"
                @click="goToPage(currentPage + 1)"
                :disabled="currentPage === totalPages"
                title="Página siguiente"
              >
                <font-awesome-icon icon="angle-right" />
              </button>

              <button
                class="btn-municipal-secondary btn-sm"
                @click="goToPage(totalPages)"
                :disabled="currentPage === totalPages"
                title="Última página"
              >
                <font-awesome-icon icon="angle-double-right" />
              </button>
            </div>
          </div>
        </div>
      </div>

      <!-- Toast Notifications -->
      <div v-if="toast.show" class="toast-notification" :class="`toast-${toast.type}`">
        <font-awesome-icon :icon="getToastIcon(toast.type)" class="toast-icon" />
        <span class="toast-message">{{ toast.message }}</span>
        <button class="toast-close" @click="hideToast">
          <font-awesome-icon icon="times" />
        </button>
      </div>

      <!-- Modal de Ayuda -->
      <DocumentationModal
        :show="showDocModal"
        :componentName="'ABCRecargos'"
        :moduleName="'cementerios'"
        :docType="docType"
        :title="'ABC de Recargos'"
        @close="showDocModal = false"
      />
    </div>
  </div>
</template>

<script setup>
import { ref, computed, nextTick } from 'vue'
import { useApi } from '@/composables/useApi'
import { useGlobalLoading } from '@/composables/useGlobalLoading'
import DocumentationModal from '@/components/common/DocumentationModal.vue'

const { execute } = useApi()
const { showLoading, hideLoading } = useGlobalLoading()

// Toast State (Manual system like reference)
const toast = ref({
  show: false,
  type: 'info',
  message: ''
})

// Toast Methods
const showToast = (type, message) => {
  toast.value = { show: true, type, message }
  setTimeout(() => {
    hideToast()
  }, 3000)
}

const hideToast = () => {
  toast.value.show = false
}

const getToastIcon = (type) => {
  const icons = {
    success: 'check-circle',
    error: 'times-circle',
    warning: 'exclamation-triangle',
    info: 'info-circle'
  }
  return icons[type] || 'info-circle'
}

// Documentación y Ayuda
const showDocModal = ref(false)
const docType = ref('ayuda')

const abrirAyuda = () => {
  docType.value = 'ayuda'
  showDocModal.value = true
}

const abrirDocumentacion = () => {
  docType.value = 'documentacion'
  showDocModal.value = true
}

// Estado
const mostrarFormulario = ref(false)
const modoEdicion = ref(false)
const porcentajeInput = ref(null)
const selectedRow = ref(null)
const hasSearched = ref(false)

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

// Paginación para historial
const currentPage = ref(1)
const itemsPerPage = ref(10)

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

// Paginación - Computed
const totalRecords = computed(() => recargosDelMes.value.length)

const totalPages = computed(() => {
  return Math.ceil(totalRecords.value / itemsPerPage.value)
})

const paginatedRecargos = computed(() => {
  const start = (currentPage.value - 1) * itemsPerPage.value
  const end = start + itemsPerPage.value
  return recargosDelMes.value.slice(start, end)
})

const visiblePages = computed(() => {
  const pages = []
  const maxVisible = 5
  let startPage = Math.max(1, currentPage.value - Math.floor(maxVisible / 2))
  let endPage = Math.min(totalPages.value, startPage + maxVisible - 1)

  if (endPage - startPage < maxVisible - 1) {
    startPage = Math.max(1, endPage - maxVisible + 1)
  }

  for (let i = startPage; i <= endPage; i++) {
    pages.push(i)
  }

  return pages
})

// Verificar si existe el recargo para el período
const verificarPeriodo = async () => {
  if (!busquedaValida.value) {
    showToast('error', 'Por favor ingrese un año y mes válidos')
    return
  }

  showLoading('Verificando período...')
  hasSearched.value = true
  selectedRow.value = null
  try {
    // Buscar recargo específico usando SP existente: sp_recargos_get
    // Base: cementerio.publico (según postgreok.csv: ta_13_recargosrcm → cementerio.publico)
    const result = await execute(
      'sp_recargos_get',
      'cementerio',
      [
        { nombre: 'p_axo', valor: busqueda.value.axo, tipo: 'integer' },
        { nombre: 'p_mes', valor: busqueda.value.mes, tipo: 'integer' }
      ],
      '',
      null,
      'publico'
    )

    // Cargar historial del mes
    await cargarRecargosDelMes()

    if (result?.result?.length > 0) {
      // Existe - modo modificación
      const recargo = result.result[0]
      modoEdicion.value = true
      formulario.value.porcentaje_parcial = recargo.porcentaje_parcial
      formulario.value.porcentaje_global = recargo.porcentaje_global
      mostrarFormulario.value = true

      await nextTick()
      if (porcentajeInput.value) {
        porcentajeInput.value.focus()
      }
    } else {
      // No existe - modo alta
      modoEdicion.value = false
      formulario.value.porcentaje_parcial = 1
      formulario.value.porcentaje_global = 0
      mostrarFormulario.value = true

      await nextTick()
      if (porcentajeInput.value) {
        porcentajeInput.value.focus()
      }
    }
  } catch (error) {
    console.error('Error al verificar período:', error)
    showToast('error', 'Error al verificar el período')
  } finally {
    hideLoading()
  }
}

// Cargar recargos del mes seleccionado
const cargarRecargosDelMes = async () => {
  try {
    // Usar SP existente: sp_recargos_list (lista todos los recargos de un mes)
    // Base: cementerio.publico (según postgreok.csv: ta_13_recargosrcm → cementerio.publico)
    const result = await execute(
      'sp_recargos_list',
      'cementerio',
      [
        { nombre: 'p_mes', valor: busqueda.value.mes, tipo: 'integer' }
      ],
      '',
      null,
      'publico'
    )

    recargosDelMes.value = result?.result || []
    currentPage.value = 1 // Reset paginación al cargar nuevos datos
  } catch (error) {
    console.error('Error al cargar recargos:', error)
    recargosDelMes.value = []
  }
}

// Guardar recargo
const guardarRecargo = async () => {
  if (!formularioValido.value) {
    showToast('error', 'Por favor complete todos los campos requeridos')
    return
  }

  showLoading('Guardando recargo...')
  try {
    // Usar SP correspondiente según modo (alta o modificación)
    // Base: cementerio.publico (según postgreok.csv: ta_13_recargosrcm → cementerio.publico)
    const spName = modoEdicion.value ? 'sp_recargos_update' : 'sp_recargos_create'

    const resultRegistro = await execute(
      spName,
      'cementerio',
      [
        { nombre: 'p_axo', valor: busqueda.value.axo, tipo: 'integer' },
        { nombre: 'p_mes', valor: busqueda.value.mes, tipo: 'integer' },
        { nombre: 'p_porcentaje_parcial', valor: formulario.value.porcentaje_parcial, tipo: 'numeric' },
        { nombre: 'p_usuario', valor: 1, tipo: 'integer' } // TODO: Obtener de sesión
      ],
      '',
      null,
      'publico'
    )

    // Verificar resultado del SP (retorna TABLE(result text))
    const resultado = resultRegistro?.result?.[0]?.result

    if (resultado === 'OK') {
      // Calcular acumulados usando SP existente: sp_recargos_acumulado, si modifican valores en fechas pasadas puede crear inconsistencias
      const resultAcumulado = await execute(
        'sp_recargos_acumulado',
        'cementerio',
        {
          p_axo: busqueda.value.axo,
          p_mes: busqueda.value.mes
        },
        '',
        null,
        'publico'
      )

      const resultadoAcumulado = resultAcumulado?.result?.[0]?.result

      if (resultadoAcumulado === 'OK') {
        showToast(
          'success',
          modoEdicion.value
            ? 'Recargo modificado y acumulados actualizados'
            : 'Recargo registrado y acumulados calculados'
        )

        // Recargar historial
        await cargarRecargosDelMes()

        // Ocultar formulario
        cancelarFormulario()
      } else {
        showToast('error', 'Recargo guardado pero error al calcular acumulados')
      }
    } else {
      showToast('error', resultado || 'Error al guardar recargo')
    }
  } catch (error) {
    console.error('Error al guardar recargo:', error)
    showToast('error', 'Error al guardar el recargo')
  } finally {
    hideLoading()
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

// Paginación - Métodos
const goToPage = (page) => {
  if (page < 1 || page > totalPages.value) return
  currentPage.value = page
  selectedRow.value = null
}

const changePageSize = (size) => {
  itemsPerPage.value = parseInt(size)
  currentPage.value = 1
  selectedRow.value = null
}

const formatNumber = (number) => {
  return new Intl.NumberFormat('es-MX').format(number)
}
</script>
