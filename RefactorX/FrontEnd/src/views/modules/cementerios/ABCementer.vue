<template>
  <div class="module-view">
    <!-- Header del módulo -->
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="monument" />
      </div>
      <div class="module-view-info">
        <h1>ABC de Fosas - Cementerios</h1>
        <p>Cementerios - Alta, Baja y Cambio de Fosas</p>
      </div>
      <div class="button-group ms-auto">
        <button
          class="btn-municipal-purple"
          @click="mostrarAyuda"
        >
          <font-awesome-icon icon="question-circle" />
          Ayuda
        </button>
      </div>
    </div>

    <div class="module-view-content">
      <!-- Sección 1: Selección de Cementerio y Búsqueda de Fosa -->
      <div class="municipal-card">
        <div class="municipal-card-header">
          <h5>
            <font-awesome-icon icon="search" />
            Búsqueda de Fosa
          </h5>
        </div>
        <div class="municipal-card-body">
          <!-- Selección de cementerio -->
          <div class="form-row">
            <div class="form-group">
              <label class="municipal-form-label required">Cementerio</label>
              <select
                class="municipal-form-control"
                v-model="busqueda.cementerio"
                @change="limpiarFosa"
              >
                <option value="">Seleccione...</option>
                <option v-for="cem in cementerios" :key="cem.cementerio" :value="cem.cementerio">
                  {{ cem.nombre_cementerio }}
                </option>
              </select>
            </div>
          </div>

          <!-- Ubicación de la fosa -->
          <div class="form-row">
            <div class="form-group">
              <label class="municipal-form-label required">Clase</label>
              <input
                type="number"
                class="municipal-form-control"
                v-model.number="busqueda.clase"
                placeholder="Número..."
              />
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Clase Alfa</label>
              <input
                type="text"
                class="municipal-form-control"
                v-model="busqueda.clase_alfa"
                maxlength="10"
                placeholder="Opcional..."
              />
            </div>
            <div class="form-group">
              <label class="municipal-form-label required">Sección</label>
              <input
                type="number"
                class="municipal-form-control"
                v-model.number="busqueda.seccion"
                placeholder="Número..."
              />
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Sección Alfa</label>
              <input
                type="text"
                class="municipal-form-control"
                v-model="busqueda.seccion_alfa"
                maxlength="10"
                placeholder="Opcional..."
              />
            </div>
          </div>

          <div class="form-row">
            <div class="form-group">
              <label class="municipal-form-label required">Línea</label>
              <input
                type="number"
                class="municipal-form-control"
                v-model.number="busqueda.linea"
                placeholder="Número..."
              />
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Línea Alfa</label>
              <input
                type="text"
                class="municipal-form-control"
                v-model="busqueda.linea_alfa"
                maxlength="10"
                placeholder="Opcional..."
              />
            </div>
            <div class="form-group">
              <label class="municipal-form-label required">Fosa</label>
              <input
                type="number"
                class="municipal-form-control"
                v-model.number="busqueda.fosa"
                placeholder="Número..."
              />
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Fosa Alfa</label>
              <input
                type="text"
                class="municipal-form-control"
                v-model="busqueda.fosa_alfa"
                maxlength="10"
                placeholder="Opcional..."
              />
            </div>
          </div>

          <div class="button-group">
            <button
              class="btn-municipal-primary"
              @click="buscarFosa"
              :disabled="loading"
            >
              <font-awesome-icon icon="search" />
              Buscar Fosa
            </button>
            <button
              v-if="!fosaEncontrada"
              class="btn-municipal-success"
              @click="nuevaFosa"
              :disabled="loading || !busqueda.cementerio"
            >
              <font-awesome-icon icon="plus" />
              Nueva Fosa
            </button>
          </div>
        </div>
      </div>

      <!-- Sección 2: Formulario de Fosa (Alta/Modificación) -->
      <div class="municipal-card" v-if="mostrarFormulario">
        <div class="municipal-card-header">
          <h5>
            <font-awesome-icon :icon="fosaEncontrada ? 'edit' : 'plus-circle'" />
            {{ fosaEncontrada ? 'Modificar Fosa' : 'Registrar Nueva Fosa' }}
            <span v-if="fosaEncontrada" class="badge-info">Folio: {{ datosFosa.control_rcm }}</span>
          </h5>
        </div>
        <div class="municipal-card-body">
          <!-- Datos principales -->
          <div class="form-row">
            <div class="form-group">
              <label class="municipal-form-label required">Último Año Pagado</label>
              <input
                type="number"
                class="municipal-form-control"
                v-model.number="formFosa.axo_pagado"
                :min="2000"
                placeholder="Año..."
              />
            </div>
            <div class="form-group">
              <label class="municipal-form-label required">Metros</label>
              <input
                type="number"
                class="municipal-form-control"
                v-model.number="formFosa.metros"
                step="0.01"
                min="0"
                placeholder="Metros cuadrados..."
              />
            </div>
            <div class="form-group">
              <label class="municipal-form-label required">Tipo de Espacio</label>
              <div class="radio-group">
                <label class="radio-label">
                  <input type="radio" v-model="formFosa.tipo" value="F" />
                  Fosa
                </label>
                <label class="radio-label">
                  <input type="radio" v-model="formFosa.tipo" value="U" />
                  Urna
                </label>
                <label class="radio-label">
                  <input type="radio" v-model="formFosa.tipo" value="G" />
                  Gaveta
                </label>
              </div>
            </div>
          </div>

          <!-- Datos del titular -->
          <div class="form-row">
            <div class="form-group full-width">
              <label class="municipal-form-label required">Nombre del Titular</label>
              <input
                type="text"
                class="municipal-form-control"
                v-model="formFosa.nombre"
                placeholder="Nombre completo..."
              />
            </div>
          </div>

          <div class="form-row">
            <div class="form-group">
              <label class="municipal-form-label">Domicilio</label>
              <input
                type="text"
                class="municipal-form-control"
                v-model="formFosa.domicilio"
                placeholder="Calle y número..."
              />
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Exterior</label>
              <input
                type="text"
                class="municipal-form-control"
                v-model="formFosa.exterior"
                placeholder="Núm. ext..."
              />
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Interior</label>
              <input
                type="text"
                class="municipal-form-control"
                v-model="formFosa.interior"
                placeholder="Núm. int..."
              />
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Colonia</label>
              <input
                type="text"
                class="municipal-form-control"
                v-model="formFosa.colonia"
                placeholder="Colonia..."
              />
            </div>
          </div>

          <!-- Datos adicionales -->
          <div class="form-row">
            <div class="form-group">
              <label class="municipal-form-label">RFC</label>
              <input
                type="text"
                class="municipal-form-control"
                v-model="formFosa.rfc"
                maxlength="13"
                placeholder="RFC..."
              />
            </div>
            <div class="form-group">
              <label class="municipal-form-label">CURP</label>
              <input
                type="text"
                class="municipal-form-control"
                v-model="formFosa.curp"
                maxlength="18"
                placeholder="CURP..."
              />
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Teléfono</label>
              <input
                type="text"
                class="municipal-form-control"
                v-model="formFosa.telefono"
                maxlength="20"
                placeholder="Teléfono..."
              />
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Clave IFE</label>
              <input
                type="text"
                class="municipal-form-control"
                v-model="formFosa.clave_ife"
                maxlength="20"
                placeholder="Clave IFE..."
              />
            </div>
          </div>

          <!-- Observaciones -->
          <div class="form-row">
            <div class="form-group full-width">
              <label class="municipal-form-label">Observaciones</label>
              <textarea
                class="municipal-form-control"
                v-model="formFosa.observaciones"
                rows="3"
                placeholder="Observaciones..."
              ></textarea>
            </div>
          </div>

          <!-- Botones -->
          <div class="button-group">
            <button
              class="btn-municipal-primary"
              @click="guardarFosa"
              :disabled="loading"
            >
              <font-awesome-icon icon="save" />
              {{ fosaEncontrada ? 'Modificar' : 'Registrar' }}
            </button>
            <button
              v-if="fosaEncontrada"
              class="btn-municipal-danger"
              @click="confirmarEliminarFosa"
              :disabled="loading"
            >
              <font-awesome-icon icon="trash" />
              Eliminar
            </button>
            <button
              class="btn-municipal-secondary"
              @click="cancelar"
              :disabled="loading"
            >
              <font-awesome-icon icon="times" />
              Cancelar
            </button>
          </div>
        </div>
      </div>

      <!-- Sección 3: Información de Fosa Encontrada (Tabs) -->
      <div class="municipal-card" v-if="fosaEncontrada">
        <div class="municipal-card-header">
          <h5>
            <font-awesome-icon icon="info-circle" />
            Información Detallada - Folio {{ datosFosa.control_rcm }}
          </h5>
        </div>
        <div class="municipal-card-body">
          <div class="tabs-container">
            <!-- Tab Headers -->
            <div class="tabs-header">
              <button
                :class="['tab-button', { 'active': tabActivo === 'pagos' }]"
                @click="tabActivo = 'pagos'"
              >
                <font-awesome-icon icon="money-bill" />
                Pagos
                <span v-if="pagos.length > 0" class="badge-count">{{ pagos.length }}</span>
              </button>
              <button
                :class="['tab-button', { 'active': tabActivo === 'adeudos' }]"
                @click="tabActivo = 'adeudos'"
              >
                <font-awesome-icon icon="file-invoice-dollar" />
                Adeudos
                <span v-if="adeudos.length > 0" class="badge-count">{{ adeudos.length }}</span>
              </button>
            </div>

            <!-- Tab Content -->
            <div class="tabs-content">
              <!-- Tab Pagos -->
              <div v-show="tabActivo === 'pagos'" class="tab-pane">
                <h6 class="tab-title">Pagos Registrados ({{ pagos.length }})</h6>
              <div class="table-responsive" v-if="pagos.length > 0">
                <table class="municipal-table">
                  <thead class="municipal-table-header">
                    <tr>
                      <th>Fecha</th>
                      <th>Recibo</th>
                      <th>Caja</th>
                      <th>Año Desde</th>
                      <th>Año Hasta</th>
                      <th>Importe</th>
                      <th>Recargos</th>
                      <th>Estado</th>
                    </tr>
                  </thead>
                  <tbody>
                    <tr v-for="pago in pagos" :key="pago.control_id">
                      <td>{{ formatearFecha(pago.fecing) }}</td>
                      <td>{{ pago.recing }}</td>
                      <td>{{ pago.cajing }}</td>
                      <td>{{ pago.axo_pago_desde }}</td>
                      <td>{{ pago.axo_pago_hasta }}</td>
                      <td>${{ formatearMoneda(pago.importe_anual) }}</td>
                      <td>${{ formatearMoneda(pago.importe_recargos) }}</td>
                      <td>
                        <span class="badge-success" v-if="pago.vigencia === 'A'">Activo</span>
                        <span class="badge-danger" v-else>Baja</span>
                      </td>
                    </tr>
                  </tbody>
                </table>
              </div>
              <p v-else class="text-center text-muted">No hay pagos registrados</p>
            </div>

              <!-- Tab Adeudos -->
              <div v-show="tabActivo === 'adeudos'" class="tab-pane">
                <h6 class="tab-title">Adeudos Vigentes ({{ adeudos.length }})</h6>
                <div class="table-responsive" v-if="adeudos.length > 0">
                <table class="municipal-table">
                  <thead class="municipal-table-header">
                    <tr>
                      <th>Año</th>
                      <th>Importe</th>
                      <th>Recargos</th>
                      <th>Desc. Importe</th>
                      <th>Desc. Recargos</th>
                      <th>Actualización</th>
                      <th>Total</th>
                      <th>Estado</th>
                    </tr>
                  </thead>
                  <tbody>
                    <tr v-for="adeudo in adeudos" :key="adeudo.id_adeudo">
                      <td><strong>{{ adeudo.axo_adeudo }}</strong></td>
                      <td>${{ formatearMoneda(adeudo.importe) }}</td>
                      <td>${{ formatearMoneda(adeudo.importe_recargos) }}</td>
                      <td>${{ formatearMoneda(adeudo.descto_impote) }}</td>
                      <td>${{ formatearMoneda(adeudo.descto_recargos) }}</td>
                      <td>${{ formatearMoneda(adeudo.actualizacion) }}</td>
                      <td class="total-amount">${{ calcularTotalAdeudo(adeudo) }}</td>
                      <td>
                        <span class="badge-warning" v-if="!adeudo.id_pago">Pendiente</span>
                        <span class="badge-success" v-else>Pagado</span>
                      </td>
                    </tr>
                  </tbody>
                </table>
              </div>
                <p v-else class="text-center text-muted">No hay adeudos registrados</p>
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- Último folio registrado -->
      <div class="municipal-card" v-if="ultimoFolio > 0">
        <div class="municipal-card-body text-center">
          <p class="info-text">
            <font-awesome-icon icon="info-circle" />
            Último folio registrado: <strong>{{ ultimoFolio }}</strong>
          </p>
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

    <!-- Modal de Ayuda/Documentación -->
    <DocumentationModal
      :show="showDocumentation"
      :componentName="'ABCementer'"
      :moduleName="'cementerios'"
      @close="closeDocumentation"
    />
  </div>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
import { FontAwesomeIcon } from '@fortawesome/vue-fontawesome'
import DocumentationModal from '@/components/common/DocumentationModal.vue'
import { useApi } from '@/composables/useApi'
import { useGlobalLoading } from '@/composables/useGlobalLoading'
import Swal from 'sweetalert2'

const { execute } = useApi()
const { showLoading, hideLoading } = useGlobalLoading()

// Sistema de Toast manual
const toast = ref({
  show: false,
  type: 'info',
  message: ''
})

const showToast = (type, message) => {
  toast.value = { show: true, type, message }
  setTimeout(() => {
    hideToast()
  }, 4000)
}

const hideToast = () => {
  toast.value.show = false
}

const getToastIcon = (type) => {
  const icons = {
    success: 'check-circle',
    error: 'exclamation-circle',
    warning: 'exclamation-triangle',
    info: 'info-circle'
  }
  return icons[type] || 'info-circle'
}

// Estado
const loading = ref(false)
const showDocumentation = ref(false)
const mostrarFormulario = ref(false)
const fosaEncontrada = ref(false)
const tabActivo = ref('pagos')

const cementerios = ref([])
const datosFosa = ref({})
const pagos = ref([])
const adeudos = ref([])
const ultimoFolio = ref(0)

const busqueda = reactive({
  cementerio: '',
  clase: null,
  clase_alfa: '',
  seccion: null,
  seccion_alfa: '',
  linea: null,
  linea_alfa: '',
  fosa: null,
  fosa_alfa: ''
})

const formFosa = reactive({
  axo_pagado: new Date().getFullYear(),
  metros: 0,
  tipo: 'F',
  nombre: '',
  domicilio: '',
  exterior: '',
  interior: '',
  colonia: '',
  observaciones: '',
  rfc: '',
  curp: '',
  telefono: '',
  clave_ife: ''
})

// Métodos
onMounted(async () => {
  await cargarCementerios()
  await cargarUltimoFolio()
})

const cargarCementerios = async () => {
  try {
    /* TODO FUTURO: Query SQL original (ABCementer.pas DFM):
    -- SQL: 'select * from tc_13_cementerios'
    */

    const response = await execute(
      'sp_abcementer_listar_cementerios',
      'cementerio',
      [],
      'function',
      null,
      'publico'
    )
    if(response?.result?.length > 0) {
      cementerios.value = response.result
    }
    
  } catch (error) {
    console.error('Error al cargar cementerios:', error)
    showToast('error', 'Error al cargar cementerios: ' + error.message)
  }
}

const cargarUltimoFolio = async () => {
  try {
    const response = await execute(
      'sp_abcementer_obtener_ultimo_folio',
      'cementerio',
      [],
      'function',
      null,
      'publico'
    )

    if (response && response.length > 0) {
      ultimoFolio.value = response[0].ultimo
    }
  } catch (error) {
    console.error('Error al obtener último folio:', error)
  }
}

const buscarFosa = async () => {
  // Validaciones
  if (!busqueda.cementerio) {
    showToast('warning', 'Seleccione un cementerio')
    return
  }
  if (!busqueda.clase || !busqueda.seccion || !busqueda.linea || !busqueda.fosa) {
    showToast('warning', 'Complete la ubicación completa (clase, sección, línea, fosa)')
    return
  }

  loading.value = true
  showLoading()

  try {
    /* TODO FUTURO: Query SQL original (ABCementer.pas DFM):
    -- SQL: 'select * from ta_13_datosrcm where cementerio=:cem and
    --       clase=:clasec and clase_alfa=:claseal and seccion=:secc and
    --       seccion_alfa=:seccional and linea=:lineac and linea_alfa=:lineaal
    --       and fosa=:fosac and fosa_alfa=:fosaal order by control_rcm desc'
    */

    const response = await execute(
      'sp_abcementer_buscar_fosa',
      'cementerio',
      [ 
        { nombre: 'p_cementerio', valor: busqueda.cementerio, tipo: 'varchar' },
        { nombre: 'p_clase', valor: busqueda.clase, tipo: 'smallint' },
        { nombre: 'p_clase_alfa', valor: busqueda.clase_alfa || '', tipo: 'varchar' },
        { nombre: 'p_seccion', valor: busqueda.seccion, tipo: 'smallint' },
        { nombre: 'p_seccion_alfa', valor: busqueda.seccion_alfa || '', tipo: 'varchar' },
        { nombre: 'p_linea', valor: busqueda.linea, tipo: 'smallint' },
        { nombre: 'p_linea_alfa', valor: busqueda.linea_alfa || '', tipo: 'varchar' },
        { nombre: 'p_fosa', valor: busqueda.fosa, tipo: 'smallint' },
        { nombre: 'p_fosa_alfa', valor: busqueda.fosa_alfa || '', tipo: 'varchar' }
      ],
      'function',
      null,
      'publico'
    )

    if (response?.result?.length > 0) {
      // Fosa encontrada
      datosFosa.value = response.result[0]
      fosaEncontrada.value = true
      mostrarFormulario.value = true

      // Cargar datos en el formulario
      formFosa.axo_pagado = datosFosa.value.axo_pagado
      formFosa.metros = parseFloat(datosFosa.value.metros || 0)
      formFosa.tipo = datosFosa.value.tipo || 'F'
      formFosa.nombre = datosFosa.value.nombre || ''
      formFosa.domicilio = datosFosa.value.domicilio || ''
      formFosa.exterior = datosFosa.value.exterior || ''
      formFosa.interior = datosFosa.value.interior || ''
      formFosa.colonia = datosFosa.value.colonia || ''
      formFosa.observaciones = datosFosa.value.observaciones || ''

      // Cargar datos adicionales, pagos y adeudos
      // await Promise.all([
      //   cargarAdicional(),
      //   cargarPagos(),
      //   cargarAdeudos()
      // ])
      await cargarAdicional()
      await cargarPagos()
      await cargarAdeudos()

      showToast('success', 'Fosa encontrada - Folio: ' + datosFosa.value.control_rcm)
    } else {
      // Fosa no encontrada
      fosaEncontrada.value = false
      showToast('info', 'No se encontró una fosa con esta ubicación')
    }
  } catch (error) {
    console.error('Error al buscar fosa:', error)
    showToast('error', 'Error al buscar fosa: ' + error.message)
  } finally {
    loading.value = false
    hideLoading()
  }
}

const cargarAdicional = async () => {
  try {
    /* TODO FUTURO: Query SQL original (ABCementer.pas DFM):
    -- SQL: 'select * from ta_13_datosrcmadic where control_rcm=:control_rcm'
    */

    const responseAdic = await execute(
      'sp_abcementer_obtener_adicional',
      'cementerio',
      [
        { nombre: 'p_control_rcm', valor: datosFosa.value.control_rcm, tipo: 'integer' }
      ],
      'function',
      null,
      'publico'
    )

    if (responseAdic?.result?.length > 0) {
      const adic = responseAdic.result[0]
      formFosa.rfc = adic.rfc || ''
      formFosa.curp = adic.curp || ''
      formFosa.telefono = adic.telefono || ''
      formFosa.clave_ife = adic.clave_ife || ''
    }
  } catch (error) {
    console.error('Error al cargar datos adicionales:', error)
  }
}

const cargarPagos = async () => {
  try {
    /* TODO FUTURO: Query SQL original (ABCementer.pas DFM):
    -- SQL: 'select * from ta_13_pagosrcm where control_rcm=:control_rcm'
    */

    const responsePagos = await execute(
      'sp_abcementer_listar_pagos',
      'cementerio',
      [
        { nombre: 'p_control_rcm', valor: datosFosa.value.control_rcm, tipo: 'integer' }
      ],
      'function',
      null,
      'publico'
    )

    
    pagos.value = responsePagos?.result || []
  } catch (error) {
    console.error('Error al cargar pagos:', error)
  }
}

const cargarAdeudos = async () => {
  try {
    const responseAde = await execute(
      'sp_abcementer_listar_adeudos',
      'cementerio',
      [
        { nombre: 'p_control_rcm', valor: datosFosa.value.control_rcm, tipo: 'integer' }
      ],
      'function',
      null,
      'publico'
    )

    adeudos.value = responseAde?.result || []
  } catch (error) {
    console.error('Error al cargar adeudos:', error)
  }
}

const nuevaFosa = () => {
  fosaEncontrada.value = false
  mostrarFormulario.value = true
  limpiarFormulario()
}

const guardarFosa = async () => {
  // Validaciones
  if (!formFosa.nombre.trim()) {
    showToast('warning', 'El nombre del titular es obligatorio')
    return
  }
  if (!formFosa.tipo) {
    showToast('warning', 'Seleccione el tipo de espacio')
    return
  }
  if (formFosa.metros <= 0) {
    showToast('warning', 'Los metros deben ser mayor a cero')
    return
  }

  loading.value = true
  showLoading()

  try {
    let response

    if (fosaEncontrada.value) {
      // Modificar fosa existente
      /* TODO FUTURO: Query SQL original (ABCementer.pas línea 295-302):
      -- UPDATE ta_13_datosrcm SET axo_pagado, metros, nombre, domicilio, exterior, interior,
      --   colonia, observaciones, usuario, fecha_mov, tipo WHERE control_rcm
      */

      response = await execute(
        'sp_abcementer_modificar',
        'cementerio',
        [
          { nombre: 'p_control_rcm', valor: datosFosa.value.control_rcm, tipo: 'integer' },
          { nombre: 'p_axo_pagado', valor: formFosa.axo_pagado, tipo: 'integer' },
          { nombre: 'p_metros', valor: formFosa.metros, tipo: 'numeric' },
          { nombre: 'p_nombre', valor: formFosa.nombre, tipo: 'varchar' },
          { nombre: 'p_domicilio', valor: formFosa.domicilio, tipo: 'varchar' },
          { nombre: 'p_exterior', valor: formFosa.exterior, tipo: 'varchar' },
          { nombre: 'p_interior', valor: formFosa.interior, tipo: 'varchar' },
          { nombre: 'p_colonia', valor: formFosa.colonia, tipo: 'varchar' },
          { nombre: 'p_observaciones', valor: formFosa.observaciones, tipo: 'text' },
          { nombre: 'p_tipo', valor: formFosa.tipo, tipo: 'varchar' },
          { nombre: 'p_usuario', valor: 1, tipo: 'integer' },
          { nombre: 'p_rfc', valor: formFosa.rfc || null, tipo: 'varchar' },
          { nombre: 'p_curp', valor: formFosa.curp || null, tipo: 'varchar' },
          { nombre: 'p_telefono', valor: formFosa.telefono || null, tipo: 'varchar' },
          { nombre: 'p_clave_ife', valor: formFosa.clave_ife || null, tipo: 'varchar' }
        ],
        'function',
        null,
        'publico'
      )
    } else {
      // Registrar nueva fosa
      /* TODO FUTURO: Query SQL original (ABCementer.pas línea 183-191):
      -- INSERT INTO ta_13_datosrcm VALUES(0, cementerio, clase, clase_alfa, seccion, seccion_alfa,
      --   linea, linea_alfa, fosa, fosa_alfa, axo_pagado, metros, nombre, domicilio, exterior,
      --   interior, colonia, observaciones, usuario, today, tipo, today, 'V')
      */

      response = await execute(
        'sp_abcementer_registrar',
        'cementerio',
        [
          { nombre: 'p_cementerio', valor: busqueda.cementerio, tipo: 'varchar' },
          { nombre: 'p_clase', valor: busqueda.clase, tipo: 'smallint' },
          { nombre: 'p_clase_alfa', valor: busqueda.clase_alfa || '', tipo: 'varchar' },
          { nombre: 'p_seccion', valor: busqueda.seccion, tipo: 'smallint' },
          { nombre: 'p_seccion_alfa', valor: busqueda.seccion_alfa || '', tipo: 'varchar' },
          { nombre: 'p_linea', valor: busqueda.linea, tipo: 'smallint' },
          { nombre: 'p_linea_alfa', valor: busqueda.linea_alfa || '', tipo: 'varchar' },
          { nombre: 'p_fosa', valor: busqueda.fosa, tipo: 'smallint' },
          { nombre: 'p_fosa_alfa', valor: busqueda.fosa_alfa || '', tipo: 'varchar' },
          { nombre: 'p_axo_pagado', valor: formFosa.axo_pagado, tipo: 'integer' },
          { nombre: 'p_metros', valor: formFosa.metros, tipo: 'numeric' },
          { nombre: 'p_nombre', valor: formFosa.nombre, tipo: 'varchar' },
          { nombre: 'p_domicilio', valor: formFosa.domicilio, tipo: 'varchar' },
          { nombre: 'p_exterior', valor: formFosa.exterior, tipo: 'varchar' },
          { nombre: 'p_interior', valor: formFosa.interior, tipo: 'varchar' },
          { nombre: 'p_colonia', valor: formFosa.colonia, tipo: 'varchar' },
          { nombre: 'p_observaciones', valor: formFosa.observaciones, tipo: 'text' },
          { nombre: 'p_tipo', valor: formFosa.tipo, tipo: 'varchar' },
          { nombre: 'p_usuario', valor: 1, tipo: 'integer' },
          { nombre: 'p_rfc', valor: formFosa.rfc || null, tipo: 'varchar' },
          { nombre: 'p_curp', valor: formFosa.curp || null, tipo: 'varchar' },
          { nombre: 'p_telefono', valor: formFosa.telefono || null, tipo: 'varchar' },
          { nombre: 'p_clave_ife', valor: formFosa.clave_ife || null, tipo: 'varchar' }
        ],
        'function',
        null,
        'publico'
      )
    }

    // Manejar respuesta con o sin .result
    const resultado = response?.result?.[0] || response?.[0]
    console.log('📝 GUARDAR FOSA - Respuesta completa:', response)
    console.log('📝 GUARDAR FOSA - Resultado procesado:', resultado)

    if (resultado && resultado.resultado === 'S') {
      showToast('success', resultado.mensaje)

      if (!fosaEncontrada.value && resultado.control_rcm) {
        showToast('success', 'Folio generado: ' + resultado.control_rcm)
      }

      await cargarUltimoFolio()
      cancelar()
    } else {
      const mensajeError = resultado?.mensaje || 'Error al guardar fosa'
      showToast('error', mensajeError)
      console.error('❌ Error en respuesta:', response)
    }
  } catch (error) {
    console.error('Error al guardar fosa:', error)
    showToast('error', 'Error al guardar fosa: ' + error.message)
  } finally {
    loading.value = false
    hideLoading()
  }
}

const confirmarEliminarFosa = async () => {
  const result = await Swal.fire({
    title: '¿Eliminar fosa?',
    text: `¿Está seguro de eliminar la fosa ${datosFosa.value.control_rcm}? Esta acción es reversible (baja lógica).`,
    icon: 'warning',
    showCancelButton: true,
    confirmButtonText: 'Sí, eliminar',
    cancelButtonText: 'Cancelar',
    confirmButtonColor: '#dc3545',
    cancelButtonColor: '#6c757d'
  })

  if (result.isConfirmed) {
    await eliminarFosa()
  }
}

const eliminarFosa = async () => {
  loading.value = true
  showLoading()

  try {
    /* TODO FUTURO: Query SQL original (ABCementer.pas línea 334-338):
    -- Histórico + UPDATE vigencia='B' WHERE control_rcm
    */

    const response = await execute(
      'sp_abcementer_eliminar',
      'cementerio',
      [
        { nombre: 'p_control_rcm', valor: datosFosa.value.control_rcm, tipo: 'integer' },
        { nombre: 'p_usuario', valor: 1, tipo: 'integer' }
      ],
      'function',
      null,
      'publico'
    )

    // Manejar respuesta con o sin .result
    const resultado = response?.result?.[0] || response?.[0]
    console.log('🗑️ ELIMINAR FOSA - Respuesta completa:', response)
    console.log('🗑️ ELIMINAR FOSA - Resultado procesado:', resultado)

    if (resultado && resultado.resultado === 'S') {
      showToast('success', resultado.mensaje)
      cancelar()
    } else {
      const mensajeError = resultado?.mensaje || 'Error al eliminar fosa'
      showToast('error', mensajeError)
      console.error('❌ Error en respuesta:', response)
    }
  } catch (error) {
    console.error('Error al eliminar fosa:', error)
    showToast('error', 'Error al eliminar fosa: ' + error.message)
  } finally {
    loading.value = false
    hideLoading()
  }
}

// Métodos de ayuda/documentación
const mostrarAyuda = () => {
  showDocumentation.value = true
}

const closeDocumentation = () => {
  showDocumentation.value = false
}

const cancelar = () => {
  mostrarFormulario.value = false
  fosaEncontrada.value = false
  limpiarFormulario()
  limpiarFosa()
}

const limpiarFormulario = () => {
  formFosa.axo_pagado = new Date().getFullYear()
  formFosa.metros = 0
  formFosa.tipo = 'F'
  formFosa.nombre = ''
  formFosa.domicilio = ''
  formFosa.exterior = ''
  formFosa.interior = ''
  formFosa.colonia = ''
  formFosa.observaciones = ''
  formFosa.rfc = ''
  formFosa.curp = ''
  formFosa.telefono = ''
  formFosa.clave_ife = ''
}

const limpiarFosa = () => {
  datosFosa.value = {}
  pagos.value = []
  adeudos.value = []
  fosaEncontrada.value = false
  mostrarFormulario.value = false
}

const formatearFecha = (fecha) => {
  if (!fecha) return '-'
  return new Date(fecha).toLocaleDateString('es-MX')
}

const formatearMoneda = (valor) => {
  if (!valor) return '0.00'
  return parseFloat(valor).toFixed(2)
}

const calcularTotalAdeudo = (adeudo) => {
  const importe = parseFloat(adeudo.importe || 0)
  const recargos = parseFloat(adeudo.importe_recargos || 0)
  const descImporte = parseFloat(adeudo.descto_impote || 0)
  const descRecargos = parseFloat(adeudo.descto_recargos || 0)
  const actualizacion = parseFloat(adeudo.actualizacion || 0)

  return (importe + recargos - descImporte - descRecargos + actualizacion).toFixed(2)
}
</script>
