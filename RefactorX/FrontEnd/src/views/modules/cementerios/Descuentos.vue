<template>
  <div class="module-view">
    <!-- Header -->
    <div class="module-view-header">
      <div class="module-title-section">
        <font-awesome-icon icon="percentage module-icon" />
        <div>
          <h1 class="module-view-info">Descuentos</h1>
          <p class="module-subtitle">Aplicación de descuentos a folios</p>
        </div>
      </div>
      <div class="module-actions">
        <button class="btn-help" @click="mostrarAyuda = true">
          <font-awesome-icon icon="question-circle" />
          Ayuda
        </button>
      </div>
    </div>

    <!-- Paso 1: Búsqueda de Folio -->
    <div class="municipal-card">
      <div class="municipal-card-header">
        <font-awesome-icon icon="search" />
        Paso 1: Búsqueda de Folio
      </div>
      <div class="municipal-card-body">
        <div class="form-grid-two">
          <div class="form-group">
            <label class="form-label required">Folio</label>
            <input
              type="number"
              v-model.number="folioSearch"
              class="form-input"
              placeholder="Ingrese número de folio"
              @keyup.enter="buscarFolio"
            />
          </div>
          <div class="form-group align-end">
            <button
              class="btn-municipal-primary"
              @click="buscarFolio"
              :disabled="!folioSearch || folioSearch <= 0"
            >
              <font-awesome-icon icon="search" />
              Buscar Folio
            </button>
          </div>
        </div>
      </div>
    </div>

    <!-- Paso 2: Información del Folio -->
    <div v-if="folioData" class="municipal-card mt-3">
      <div class="municipal-card-header">
        <font-awesome-icon icon="info-circle" />
        Paso 2: Información del Folio
      </div>
      <div class="municipal-card-body">
        <div class="info-section">
          <h3 class="info-title">Datos del Folio</h3>
          <div class="info-grid">
            <div class="info-item">
              <span class="info-label">Folio:</span>
              <span class="info-value">{{ folioData.control_rcm }}</span>
            </div>
            <div class="info-item">
              <span class="info-label">Cementerio:</span>
              <span class="info-value">{{ folioData.cementerio }}</span>
            </div>
            <div class="info-item">
              <span class="info-label">Clase:</span>
              <span class="info-value">{{ folioData.clase_alfa }}</span>
            </div>
            <div class="info-item">
              <span class="info-label">Sección:</span>
              <span class="info-value">{{ folioData.seccion_alfa }}</span>
            </div>
            <div class="info-item">
              <span class="info-label">Línea:</span>
              <span class="info-value">{{ folioData.linea_alfa }}</span>
            </div>
            <div class="info-item">
              <span class="info-label">Fosa:</span>
              <span class="info-value">{{ folioData.fosa_alfa }}</span>
            </div>
            <div class="info-item full-width">
              <span class="info-label">Nombre:</span>
              <span class="info-value">{{ folioData.nombre }}</span>
            </div>
            <div class="info-item full-width">
              <span class="info-label">Domicilio:</span>
              <span class="info-value">
                {{ folioData.domicilio }}
                {{ folioData.exterior ? 'Ext. ' + folioData.exterior : '' }}
                {{ folioData.interior ? 'Int. ' + folioData.interior : '' }}
              </span>
            </div>
            <div class="info-item full-width">
              <span class="info-label">Colonia:</span>
              <span class="info-value">{{ folioData.colonia }}</span>
            </div>
          </div>
        </div>

        <!-- Adeudos -->
        <div v-if="adeudos.length > 0" class="mt-3">
          <h3 class="info-title">Adeudos Vigentes</h3>
          <div class="table-container">
            <table class="municipal-table">
              <thead class="municipal-table-header">
                <tr>
                  <th>Año</th>
                  <th>Importe</th>
                  <th>Recargos</th>
                  <th>Desc. Importe</th>
                  <th>Desc. Recargos</th>
                  <th>Total</th>
                  <th>Acciones</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="adeudo in adeudos" :key="adeudo.id_adeudo">
                  <td>{{ adeudo.axo_adeudo }}</td>
                  <td>{{ formatCurrency(adeudo.importe) }}</td>
                  <td>{{ formatCurrency(adeudo.importe_recargos) }}</td>
                  <td>{{ formatCurrency(adeudo.descto_impote) }}</td>
                  <td>{{ formatCurrency(adeudo.descto_recargos) }}</td>
                  <td class="text-bold">
                    {{ formatCurrency(
                      adeudo.importe + adeudo.importe_recargos -
                      adeudo.descto_impote - adeudo.descto_recargos
                    ) }}
                  </td>
                  <td>
                    <button
                      v-if="!tieneDescuento(adeudo.axo_adeudo)"
                      class="btn-action-primary"
                      @click="seleccionarAdeudo(adeudo)"
                      title="Aplicar descuento"
                    >
                      <font-awesome-icon icon="plus" />
                    </button>
                    <span v-else class="badge-success">Con descuento</span>
                  </td>
                </tr>
              </tbody>
            </table>
          </div>
        </div>

        <!-- Sin adeudos - Opción de reactivar -->
        <div v-if="adeudos.length === 0" class="alert-info mt-3">
          <font-awesome-icon icon="info-circle" />
          <div>
            <strong>Sin adeudos vigentes</strong>
            <p>Este folio no tiene adeudos vigentes. Puede reactivarlo si es necesario.</p>
            <div class="form-group mt-2">
              <label class="checkbox-label">
                <input type="checkbox" v-model="modoReactivar" />
                Reactivar folio
              </label>
            </div>
            <button
              v-if="modoReactivar"
              class="btn-municipal-primary mt-2"
              @click="reactivarFolio"
            >
              <font-awesome-icon icon="redo" />
              Reactivar Folio
            </button>
          </div>
        </div>
      </div>
    </div>

    <!-- Paso 3: Aplicar Descuento -->
    <div v-if="adeudoSeleccionado" class="municipal-card mt-3">
      <div class="municipal-card-header">
        <font-awesome-icon icon="tag" />
        Paso 3: Aplicar Descuento al Año {{ adeudoSeleccionado.axo_adeudo }}
      </div>
      <div class="municipal-card-body">
        <div class="alert-info mb-3">
          <font-awesome-icon icon="info-circle" />
          <span>Seleccione el tipo de descuento a aplicar</span>
        </div>

        <div v-if="tiposDescuento.length > 0" class="form-grid-two">
          <div class="form-group">
            <label class="form-label required">Tipo de Descuento</label>
            <select v-model="descuentoSeleccionado" class="form-input">
              <option :value="null">-- Seleccione --</option>
              <option
                v-for="tipo in tiposDescuento"
                :key="tipo.tipo_descto"
                :value="tipo"
              >
                {{ tipo.tipo_descto }} - {{ tipo.descrip_descto }} ({{ tipo.porcentaje }}%)
              </option>
            </select>
          </div>
        </div>

        <div v-if="descuentoSeleccionado" class="summary-box mt-3">
          <div class="summary-item">
            <span class="summary-label">Importe Base:</span>
            <span class="summary-value">{{ formatCurrency(adeudoSeleccionado.importe) }}</span>
          </div>
          <div class="summary-item">
            <span class="summary-label">Recargos:</span>
            <span class="summary-value">{{ formatCurrency(adeudoSeleccionado.importe_recargos) }}</span>
          </div>
          <div class="summary-item">
            <span class="summary-label">Porcentaje Descuento:</span>
            <span class="summary-value primary">{{ descuentoSeleccionado.porcentaje }}%</span>
          </div>
          <div class="summary-item">
            <span class="summary-label">Descuento Importe:</span>
            <span class="summary-value success">
              {{ formatCurrency(calcularDescuento(adeudoSeleccionado.importe)) }}
            </span>
          </div>
          <div class="summary-item">
            <span class="summary-label">Descuento Recargos:</span>
            <span class="summary-value success">
              {{ formatCurrency(calcularDescuento(adeudoSeleccionado.importe_recargos)) }}
            </span>
          </div>
          <div class="summary-item total">
            <span class="summary-label">Total con Descuento:</span>
            <span class="summary-value">
              {{ formatCurrency(calcularTotalConDescuento()) }}
            </span>
          </div>
        </div>

        <div class="form-actions">
          <button
            class="btn-municipal-secondary"
            @click="cancelarDescuento"
          >
            <font-awesome-icon icon="times" />
            Cancelar
          </button>
          <button
            class="btn-municipal-primary"
            @click="aplicarDescuento"
            :disabled="!descuentoSeleccionado"
          >
            <font-awesome-icon icon="save" />
            Aplicar Descuento
          </button>
        </div>
      </div>
    </div>

    <!-- Paso 4: Descuentos Aplicados -->
    <div v-if="descuentosAplicados.length > 0" class="municipal-card mt-3">
      <div class="municipal-card-header">
        <font-awesome-icon icon="list" />
        Descuentos Aplicados
      </div>
      <div class="municipal-card-body">
        <div class="table-container">
          <table class="municipal-table">
            <thead class="municipal-table-header">
              <tr>
                <th>Año</th>
                <th>Tipo</th>
                <th>Descripción</th>
                <th>Descuento %</th>
                <th>Usuario</th>
                <th>Fecha</th>
                <th>Estado</th>
                <th>Acciones</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="desc in descuentosAplicados" :key="desc.control_des">
                <td>{{ desc.axo_descto }}</td>
                <td>{{ desc.tipo_descto }}</td>
                <td>{{ desc.descrip_descto }}</td>
                <td>{{ desc.descuento }}%</td>
                <td>{{ desc.nombre }}</td>
                <td>{{ formatDate(desc.fecha_alta) }}</td>
                <td>
                  <span :class="desc.vigencia === 'V' ? 'badge-success' : 'badge-danger'">
                    {{ desc.vigencia === 'V' ? 'Vigente' : 'Cancelado' }}
                  </span>
                </td>
                <td>
                  <button
                    v-if="desc.vigencia === 'V'"
                    class="btn-action-danger"
                    @click="eliminarDescuento(desc)"
                    title="Cancelar descuento"
                  >
                    <font-awesome-icon icon="trash" />
                  </button>
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
    </div>

    <!-- Modal de Ayuda -->
    <DocumentationModal
      v-if="mostrarAyuda"
      title="Ayuda - Descuentos"
      @close="mostrarAyuda = false"
    >
      <div class="help-content">
        <section class="help-section">
          <h3><font-awesome-icon icon="info-circle" /> Descripción</h3>
          <p>
            Este módulo permite aplicar descuentos a los adeudos de folios de cementerio.
            Los descuentos se aplican por año y tipo de descuento según el catálogo configurado.
          </p>
        </section>

        <section class="help-section">
          <h3><font-awesome-icon icon="list-ol" /> Proceso</h3>
          <ol>
            <li>Ingrese el número de folio y presione "Buscar Folio"</li>
            <li>El sistema mostrará la información del folio y sus adeudos vigentes</li>
            <li>Si hay adeudos, puede seleccionar un año para aplicar descuento</li>
            <li>Seleccione el tipo de descuento del catálogo disponible</li>
            <li>Revise el cálculo del descuento en el resumen</li>
            <li>Presione "Aplicar Descuento" para guardar</li>
            <li>Puede cancelar descuentos aplicados desde la tabla de descuentos</li>
          </ol>
        </section>

        <section class="help-section">
          <h3><font-awesome-icon icon="exclamation-triangle" /> Restricciones</h3>
          <ul>
            <li>Solo se puede aplicar un descuento por año por folio</li>
            <li>El folio debe tener adeudos vigentes para aplicar descuentos</li>
            <li>Los descuentos solo se aplican a adeudos no pagados</li>
            <li>Si el folio no tiene adeudos, solo puede reactivarlo</li>
          </ul>
        </section>

        <section class="help-section">
          <h3><font-awesome-icon icon="redo" /> Reactivación</h3>
          <p>
            Si un folio no tiene adeudos vigentes, puede marcarse como reactivado.
            Active la casilla "Reactivar folio" y presione el botón de reactivación.
          </p>
        </section>
      </div>
    </DocumentationModal>
  </div>
</template>

<script setup>
import { ref, computed } from 'vue'
import { useApi } from '@/composables/useApi'
import { useGlobalLoading } from '@/composables/useGlobalLoading'
import { useToast } from '@/composables/useToast'
import DocumentationModal from '@/components/common/DocumentationModal.vue'
import Swal from 'sweetalert2'

const { callProcedure } = useApi()
const { showSuccess, showError } = useToast()

// Estado
const mostrarAyuda = ref(false)
const folioSearch = ref(null)
const folioData = ref(null)
const adeudos = ref([])
const adeudoSeleccionado = ref(null)
const tiposDescuento = ref([])
const descuentoSeleccionado = ref(null)
const descuentosAplicados = ref([])
const modoReactivar = ref(false)

// Buscar folio
const buscarFolio = async () => {
  if (!folioSearch.value || folioSearch.value <= 0) {
    showError('Por favor ingrese un número de folio válido')
    return
  }

  try {
    // Buscar folio
    const result = await callProcedure('sp_cem_buscar_folio', {
      p_control_rcm: folioSearch.value
    })

    if (result.resultado === 'S' && result.data) {
      folioData.value = result.data
      await cargarAdeudos()
      await cargarDescuentos()
      await cargarTiposDescuento()
    } else {
      showError(result.mensaje || 'Folio no encontrado')
      limpiarDatos()
    }
  } catch (error) {
    console.error('Error al buscar folio:', error)
    showError('Error al buscar el folio')
    limpiarDatos()
  }
}

// Cargar adeudos del folio
const cargarAdeudos = async () => {
  try {
    const result = await callProcedure('sp_cem_listar_adeudos_folio', {
      p_control_rcm: folioSearch.value
    })

    adeudos.value = result.data || []
  } catch (error) {
    console.error('Error al cargar adeudos:', error)
    adeudos.value = []
  }
}

// Cargar descuentos aplicados
const cargarDescuentos = async () => {
  try {
    const result = await callProcedure('sp_cem_listar_descuentos_folio', {
      p_control_rcm: folioSearch.value
    })

    descuentosAplicados.value = result.data || []
  } catch (error) {
    console.error('Error al cargar descuentos:', error)
    descuentosAplicados.value = []
  }
}

// Cargar tipos de descuento
const cargarTiposDescuento = async () => {
  try {
    const currentYear = new Date().getFullYear()
    const result = await callProcedure('sp_cem_listar_tipos_descuento', {
      p_axo: currentYear
    })

    tiposDescuento.value = result.data || []
  } catch (error) {
    console.error('Error al cargar tipos de descuento:', error)
    tiposDescuento.value = []
  }
}

// Verificar si un año ya tiene descuento
const tieneDescuento = (axo) => {
  return descuentosAplicados.value.some(
    d => d.axo_descto === axo && d.vigencia === 'V'
  )
}

// Seleccionar adeudo para aplicar descuento
const seleccionarAdeudo = (adeudo) => {
  adeudoSeleccionado.value = adeudo
  descuentoSeleccionado.value = null
}

// Calcular descuento
const calcularDescuento = (monto) => {
  if (!descuentoSeleccionado.value) return 0
  return (monto * descuentoSeleccionado.value.porcentaje) / 100
}

// Calcular total con descuento
const calcularTotalConDescuento = () => {
  if (!adeudoSeleccionado.value || !descuentoSeleccionado.value) return 0

  const total = adeudoSeleccionado.value.importe + adeudoSeleccionado.value.importe_recargos
  const descuento = calcularDescuento(adeudoSeleccionado.value.importe) +
                    calcularDescuento(adeudoSeleccionado.value.importe_recargos)

  return total - descuento
}

// Aplicar descuento
const aplicarDescuento = async () => {
  if (!descuentoSeleccionado.value) {
    showError('Seleccione un tipo de descuento')
    return
  }

  try {
    const result = await callProcedure('sp_cem_gestionar_descuento', {
      p_operacion: 1, // Alta
      p_control_rcm: folioSearch.value,
      p_axo: adeudoSeleccionado.value.axo_adeudo,
      p_porcentaje: descuentoSeleccionado.value.porcentaje,
      p_tipo_descto: descuentoSeleccionado.value.tipo_descto,
      p_reactivar: 'N',
      p_usuario: 1 // TODO: Obtener de sesión
    })

    if (result.resultado === 'S') {
      showSuccess(result.mensaje)
      await cargarAdeudos()
      await cargarDescuentos()
      cancelarDescuento()
    } else {
      showError(result.mensaje || 'Error al aplicar descuento')
    }
  } catch (error) {
    console.error('Error al aplicar descuento:', error)
    showError('Error al aplicar el descuento')
  }
}

// Cancelar selección de descuento
const cancelarDescuento = () => {
  adeudoSeleccionado.value = null
  descuentoSeleccionado.value = null
}

// Eliminar descuento
const eliminarDescuento = async (descuento) => {
  const result = await Swal.fire({
    title: '¿Cancelar descuento?',
    text: `Se cancelará el descuento del ${descuento.descuento}% para el año ${descuento.axo_descto}`,
    icon: 'warning',
    showCancelButton: true,
    confirmButtonText: 'Sí, cancelar',
    cancelButtonText: 'No',
    confirmButtonColor: '#d33',
    cancelButtonColor: '#3085d6'
  })

  if (!result.isConfirmed) return

  try {
    const response = await callProcedure('sp_cem_gestionar_descuento', {
      p_operacion: 2, // Baja
      p_control_rcm: folioSearch.value,
      p_axo: descuento.axo_descto,
      p_porcentaje: descuento.descuento,
      p_tipo_descto: descuento.tipo_descto,
      p_reactivar: 'N',
      p_usuario: 1 // TODO: Obtener de sesión
    })

    if (response.resultado === 'S') {
      showSuccess(response.mensaje)
      await cargarAdeudos()
      await cargarDescuentos()
    } else {
      showError(response.mensaje || 'Error al cancelar descuento')
    }
  } catch (error) {
    console.error('Error al cancelar descuento:', error)
    showError('Error al cancelar el descuento')
  }
}

// Reactivar folio
const reactivarFolio = async () => {
  if (!modoReactivar.value) return

  try {
    const currentYear = new Date().getFullYear()
    const result = await callProcedure('sp_cem_gestionar_descuento', {
      p_operacion: 4, // Reactivar
      p_control_rcm: folioSearch.value,
      p_axo: currentYear,
      p_porcentaje: 0,
      p_tipo_descto: '',
      p_reactivar: 'S',
      p_usuario: 1 // TODO: Obtener de sesión
    })

    if (result.resultado === 'S') {
      showSuccess(result.mensaje)
      modoReactivar.value = false
      await cargarDescuentos()
    } else {
      showError(result.mensaje || 'Error al reactivar folio')
    }
  } catch (error) {
    console.error('Error al reactivar folio:', error)
    showError('Error al reactivar el folio')
  }
}

// Limpiar datos
const limpiarDatos = () => {
  folioData.value = null
  adeudos.value = []
  adeudoSeleccionado.value = null
  descuentoSeleccionado.value = null
  descuentosAplicados.value = []
  modoReactivar.value = false
}

// Formatear moneda
const formatCurrency = (value) => {
  if (value == null) return '$0.00'
  return new Intl.NumberFormat('es-MX', {
    style: 'currency',
    currency: 'MXN'
  }).format(value)
}

// Formatear fecha
const formatDate = (date) => {
  if (!date) return ''
  return new Date(date).toLocaleDateString('es-MX')
}
</script>
