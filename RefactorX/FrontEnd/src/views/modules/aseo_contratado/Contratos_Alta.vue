<template>
  <div class="module-view">
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="file-circle-plus" />
      </div>
      <div class="module-view-info">
        <h1>Alta de Contratos</h1>
        <p>Aseo Contratado - Registro de nuevos contratos</p>
      </div>
      <button type="button" class="btn-help-icon" @click="showDocumentation = true" title="Ayuda">
        <font-awesome-icon icon="question-circle" />
      </button>
    </div>

    <div class="module-view-content">
      <!-- Panel Principal -->
      <div class="municipal-card">
        <div class="municipal-card-header">
          <h5><font-awesome-icon icon="file-contract" /> Datos del Contrato</h5>
        </div>
        <div class="municipal-card-body">
          <!-- Fila 1: Contrato y Tipo de Aseo -->
          <div class="form-row">
            <div class="form-group col-md-4">
              <label class="municipal-form-label required">No. Contrato</label>
              <input
                type="number"
                v-model.number="formData.num_contrato"
                class="municipal-form-control"
                min="1"
                required
              />
            </div>
            <div class="form-group col-md-8">
              <label class="municipal-form-label required">Tipo de Aseo</label>
              <select v-model="formData.ctrol_aseo" class="municipal-form-control" required>
                <option value="">Seleccione...</option>
                <option v-for="tipo in tiposAseo" :key="tipo.ctrol_aseo" :value="tipo.ctrol_aseo">
                  {{ tipo.display_text }}
                </option>
              </select>
            </div>
          </div>

          <!-- Fila 2: Empresa -->
          <div class="form-row">
            <div class="form-group col-md-3">
              <label class="municipal-form-label required">No. Empresa</label>
              <div class="input-group">
                <input
                  type="number"
                  v-model.number="formData.num_empresa"
                  class="municipal-form-control"
                  min="1"
                  required
                  @blur="cargarInfoEmpresa"
                />
                <button type="button" class="btn-municipal-secondary" @click="abrirBuscadorEmpresa">
                  <font-awesome-icon icon="search" />
                </button>
              </div>
            </div>
            <div class="form-group col-md-5">
              <label class="municipal-form-label">Nombre Empresa</label>
              <input type="text" :value="empresaInfo.nombre" class="municipal-form-control" readonly />
            </div>
            <div class="form-group col-md-4">
              <label class="municipal-form-label">Representante</label>
              <input type="text" :value="empresaInfo.representante" class="municipal-form-control" readonly />
            </div>
          </div>
        </div>
      </div>

      <!-- Datos de Recoleccion -->
      <div class="municipal-card mt-3">
        <div class="municipal-card-header">
          <h5><font-awesome-icon icon="truck" /> Datos de Recoleccion</h5>
        </div>
        <div class="municipal-card-body">
          <div class="form-row">
            <div class="form-group col-md-8">
              <label class="municipal-form-label required">Unidad de Recoleccion</label>
              <select v-model="formData.ctrol_recolec" class="municipal-form-control" required @change="onUnidadChange">
                <option value="">Seleccione...</option>
                <option v-for="unidad in unidadesRecolec" :key="unidad.ctrol_recolec" :value="unidad.ctrol_recolec">
                  {{ unidad.display_text }}
                </option>
              </select>
            </div>
            <div class="form-group col-md-4">
              <label class="municipal-form-label required">Cantidad</label>
              <input
                type="number"
                v-model.number="formData.cantidad"
                class="municipal-form-control"
                min="1"
                required
              />
            </div>
          </div>
        </div>
      </div>

      <!-- Datos Anexos -->
      <div class="municipal-card mt-3">
        <div class="municipal-card-header">
          <h5><font-awesome-icon icon="map-marker-alt" /> Datos Anexos</h5>
        </div>
        <div class="municipal-card-body">
          <div class="form-row">
            <div class="form-group col-md-12">
              <label class="municipal-form-label required">Domicilio</label>
              <input
                type="text"
                v-model="formData.domicilio"
                class="municipal-form-control"
                maxlength="200"
                required
              />
            </div>
          </div>

          <div class="form-row">
            <div class="form-group col-md-2">
              <label class="municipal-form-label required">Sector</label>
              <select v-model="formData.sector" class="municipal-form-control" required>
                <option value="H">H</option>
                <option value="J">J</option>
                <option value="R">R</option>
                <option value="L">L</option>
              </select>
            </div>
            <div class="form-group col-md-5">
              <label class="municipal-form-label required">Zona</label>
              <select v-model="formData.ctrol_zona" class="municipal-form-control" required>
                <option value="">Seleccione...</option>
                <option v-for="zona in zonas" :key="zona.ctrol_zona" :value="zona.ctrol_zona">
                  {{ zona.display_text }}
                </option>
              </select>
            </div>
            <div class="form-group col-md-5">
              <label class="municipal-form-label required">Recaudadora</label>
              <select v-model="formData.id_rec" class="municipal-form-control" required>
                <option value="">Seleccione...</option>
                <option v-for="rec in recaudadoras" :key="rec.id_rec" :value="rec.id_rec">
                  {{ rec.display_text }}
                </option>
              </select>
            </div>
          </div>
        </div>
      </div>

      <!-- Fecha de Obligacion -->
      <div class="municipal-card mt-3">
        <div class="municipal-card-header">
          <h5><font-awesome-icon icon="calendar-alt" /> Fecha de Obligacion</h5>
        </div>
        <div class="municipal-card-body">
          <div class="form-row">
            <div class="form-group col-md-4">
              <label class="municipal-form-label required">Anio</label>
              <input
                type="number"
                v-model.number="formData.anio"
                class="municipal-form-control"
                :min="1989"
                :max="ejercicioActual"
                required
              />
            </div>
            <div class="form-group col-md-4">
              <label class="municipal-form-label required">Mes</label>
              <select v-model="formData.mes" class="municipal-form-control" required>
                <option value="1">01 - Enero</option>
                <option value="2">02 - Febrero</option>
                <option value="3">03 - Marzo</option>
                <option value="4">04 - Abril</option>
                <option value="5">05 - Mayo</option>
                <option value="6">06 - Junio</option>
                <option value="7">07 - Julio</option>
                <option value="8">08 - Agosto</option>
                <option value="9">09 - Septiembre</option>
                <option value="10">10 - Octubre</option>
                <option value="11">11 - Noviembre</option>
                <option value="12">12 - Diciembre</option>
              </select>
            </div>
            <div class="form-group col-md-4">
              <label class="municipal-form-label">Costo Unidad</label>
              <input
                type="text"
                :value="formatCurrency(costoUnidad)"
                class="municipal-form-control text-right"
                readonly
              />
            </div>
          </div>
        </div>
      </div>

      <!-- Botones de Accion -->
      <div class="municipal-card mt-3">
        <div class="municipal-card-body">
          <div class="button-group">
            <button
              type="button"
              class="btn-municipal-primary"
              @click="ejecutar"
              :disabled="!isFormValid"
            >
              <font-awesome-icon icon="save" /> Ejecutar
            </button>
            <button
              type="button"
              class="btn-municipal-secondary"
              @click="cancelar"
            >
              <font-awesome-icon icon="times" /> Cancelar
            </button>
          </div>
        </div>
      </div>
    </div>

    <!-- Panel de Busqueda de Empresas -->
    <div v-if="mostrarPanelEmpresas" class="modal-overlay" @click.self="cerrarPanelEmpresas">
      <div class="modal-panel">
        <div class="modal-panel-header">
          <h5><font-awesome-icon icon="building" /> Buscar Empresa</h5>
          <button type="button" class="btn-close" @click="cerrarPanelEmpresas"></button>
        </div>
        <div class="modal-panel-body">
          <div class="form-row mb-3">
            <div class="form-group col-md-10">
              <label class="municipal-form-label">Buscar por Nombre</label>
              <input
                type="text"
                v-model="busquedaEmpresa"
                class="municipal-form-control"
                placeholder="Ingrese nombre de empresa..."
                @keyup.enter="buscarEmpresas"
              />
            </div>
            <div class="form-group col-md-2 d-flex align-items-end">
              <button type="button" class="btn-municipal-primary w-100" @click="buscarEmpresas">
                <font-awesome-icon icon="search" /> Buscar
              </button>
            </div>
          </div>

          <!-- Tabla de resultados -->
          <div v-if="empresasEncontradas.length > 0" class="table-responsive">
            <table class="municipal-table">
              <thead>
                <tr>
                  <th>No. Empresa</th>
                  <th>Nombre</th>
                  <th>Representante</th>
                  <th>Accion</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="emp in empresasEncontradas" :key="emp.num_empresa">
                  <td>{{ emp.num_empresa }}</td>
                  <td>{{ emp.descripcion }}</td>
                  <td>{{ emp.representante }}</td>
                  <td>
                    <button
                      type="button"
                      class="btn-municipal-primary btn-sm"
                      @click="seleccionarEmpresa(emp)"
                    >
                      Seleccionar
                    </button>
                  </td>
                </tr>
              </tbody>
            </table>
          </div>

          <div v-else-if="busquedaRealizada" class="alert alert-warning">
            No se encontraron empresas con ese nombre.
            <button type="button" class="btn-municipal-secondary btn-sm ms-2" @click="crearNuevaEmpresa">
              Crear nueva empresa
            </button>
          </div>
        </div>
        <div class="modal-panel-footer">
          <button type="button" class="btn-municipal-secondary" @click="cerrarPanelEmpresas">
            Cancelar
          </button>
        </div>
      </div>
    </div>

    <!-- Modal de Documentacion -->
    <DocumentationModal :show="showDocumentation" @close="showDocumentation = false" title="Ayuda - Alta de Contratos">
      <h3>Alta de Contratos</h3>
      <p>Este modulo permite registrar nuevos contratos de aseo contratado.</p>

      <h4>Campos Requeridos:</h4>
      <ul>
        <li><strong>No. Contrato:</strong> Numero unico del contrato</li>
        <li><strong>Tipo de Aseo:</strong> Categoria del servicio (Centro, Hospitalario, Ordinario)</li>
        <li><strong>No. Empresa:</strong> Empresa que contrata el servicio</li>
        <li><strong>Unidad de Recoleccion:</strong> Tipo de unidad y cantidad</li>
        <li><strong>Domicilio:</strong> Ubicacion del servicio</li>
        <li><strong>Sector:</strong> H, J, R o L</li>
        <li><strong>Zona y Recaudadora:</strong> Asignacion administrativa</li>
        <li><strong>Anio/Mes:</strong> Inicio de obligacion</li>
      </ul>

      <h4>Proceso:</h4>
      <ol>
        <li>Se valida que la empresa exista</li>
        <li>Se valida que el contrato no exista</li>
        <li>Se crea el contrato con status Vigente (V)</li>
        <li>Se generan los pagos desde el mes de inicio hasta diciembre</li>
        <li>Si existen costos del siguiente anio, se generan pagos de enero a diciembre</li>
      </ol>
    </DocumentationModal>
  </div>
</template>

<script setup>
import { ref, computed, onMounted, watch } from 'vue'
import { useRouter } from 'vue-router'
import DocumentationModal from '@/components/common/DocumentationModal.vue'
import { useApi } from '@/composables/useApi'
import { useGlobalLoading } from '@/composables/useGlobalLoading'
import { useLicenciasErrorHandler } from '@/composables/useLicenciasErrorHandler'
import Swal from 'sweetalert2'

const BASE_DB = 'aseo_contratado'
const SCHEMA = 'publico'

const { execute } = useApi()
const { showToast, handleApiError } = useLicenciasErrorHandler()
const { showLoading, hideLoading } = useGlobalLoading()
const router = useRouter()

// Estado del formulario
const showDocumentation = ref(false)
const mostrarPanelEmpresas = ref(false)
const busquedaEmpresa = ref('')
const busquedaRealizada = ref(false)
const empresasEncontradas = ref([])

// Datos de combos
const tiposAseo = ref([])
const zonas = ref([])
const recaudadoras = ref([])
const unidadesRecolec = ref([])

// Ejercicio actual
const ejercicioActual = new Date().getFullYear()

// Info de empresa seleccionada
const empresaInfo = ref({
  nombre: '',
  representante: ''
})

// Costo de unidad seleccionada
const costoUnidad = ref(0)

// Datos del formulario - igual que Delphi
const formData = ref({
  num_contrato: null,
  ctrol_aseo: '',
  num_empresa: null,
  ctrol_recolec: '',
  cantidad: 1,
  domicilio: '',
  sector: 'H',
  ctrol_zona: '',
  id_rec: '',
  anio: ejercicioActual,
  mes: new Date().getMonth() + 1
})

// Validacion del formulario
const isFormValid = computed(() => {
  return formData.value.num_contrato &&
         formData.value.num_contrato > 0 &&
         formData.value.ctrol_aseo &&
         formData.value.num_empresa &&
         formData.value.num_empresa > 0 &&
         formData.value.ctrol_recolec &&
         formData.value.cantidad > 0 &&
         formData.value.domicilio.trim() !== '' &&
         formData.value.sector &&
         formData.value.ctrol_zona &&
         formData.value.id_rec &&
         formData.value.anio >= 1989 &&
         formData.value.anio <= ejercicioActual &&
         formData.value.mes >= 1 &&
         formData.value.mes <= 12
})

// Formatear moneda
const formatCurrency = (value) => {
  return new Intl.NumberFormat('es-MX', {
    style: 'currency',
    currency: 'MXN'
  }).format(value || 0)
}

// Cargar tipos de aseo
const cargarTiposAseo = async () => {
  try {
    const data = await execute('sp_aseo_tipos_aseo_combo', BASE_DB, [], '', null, SCHEMA)
    if (data && Array.isArray(data)) {
      tiposAseo.value = data
      if (data.length > 0) {
        formData.value.ctrol_aseo = data[0].ctrol_aseo
      }
    }
  } catch (error) {
    hideLoading()
    handleApiError(error, 'Error al cargar tipos de aseo')
  }
}

// Cargar zonas
const cargarZonas = async () => {
  try {
    const data = await execute('sp_aseo_zonas_combo', BASE_DB, [], '', null, SCHEMA)
    if (data && Array.isArray(data)) {
      zonas.value = data
      if (data.length > 0) {
        formData.value.ctrol_zona = data[0].ctrol_zona
      }
    }
  } catch (error) {
    hideLoading()
    handleApiError(error, 'Error al cargar zonas')
  }
}

// Cargar recaudadoras
const cargarRecaudadoras = async () => {
  try {
    const data = await execute('sp_aseo_recaudadoras_combo', BASE_DB, [], '', null, SCHEMA)
    if (data && Array.isArray(data)) {
      recaudadoras.value = data
      if (data.length > 0) {
        formData.value.id_rec = data[0].id_rec
      }
    }
  } catch (error) {
    hideLoading()
    handleApiError(error, 'Error al cargar recaudadoras')
  }
}

// Cargar unidades de recoleccion por ejercicio
const cargarUnidadesRecolec = async () => {
  try {
    const params = [
      { nombre: 'p_ejercicio', valor: formData.value.anio, tipo: 'integer' }
    ]
    const data = await execute('sp_aseo_unidades_combo', BASE_DB, params, '', null, SCHEMA)
    if (data && Array.isArray(data)) {
      unidadesRecolec.value = data
      if (data.length > 0) {
        formData.value.ctrol_recolec = data[0].ctrol_recolec
        costoUnidad.value = data[0].costo_unidad || 0
      }
    }
  } catch (error) {
    hideLoading()
    handleApiError(error, 'Error al cargar unidades')
  }
}

// Cuando cambia el anio, recargar unidades
watch(() => formData.value.anio, async (newVal) => {
  if (newVal && newVal >= 1989) {
    await cargarUnidadesRecolec()
  }
})

// Cuando cambia la unidad seleccionada
const onUnidadChange = () => {
  const unidad = unidadesRecolec.value.find(u => u.ctrol_recolec === formData.value.ctrol_recolec)
  if (unidad) {
    costoUnidad.value = unidad.costo_unidad || 0
  }
}

// Cargar info de empresa por numero
const cargarInfoEmpresa = async () => {
  if (!formData.value.num_empresa || formData.value.num_empresa <= 0) {
    empresaInfo.value = { nombre: '', representante: '' }
    return
  }

  try {
    const params = [
      { nombre: 'p_num_contrato', valor: formData.value.num_contrato || 0, tipo: 'integer' },
      { nombre: 'p_num_empresa', valor: formData.value.num_empresa, tipo: 'integer' },
      { nombre: 'p_ctrol_aseo', valor: formData.value.ctrol_aseo || 1, tipo: 'integer' }
    ]
    const data = await execute('sp_aseo_verificar_contrato_empresa', BASE_DB, params, '', null, SCHEMA)
    if (data && data.length > 0) {
      const result = data[0]
      if (result.empresa_existe) {
        empresaInfo.value = {
          nombre: result.nombre_empresa || '',
          representante: result.representante || ''
        }
      } else {
        empresaInfo.value = { nombre: '', representante: '' }
        showToast('La empresa no existe', 'warning')
      }
    }
  } catch (error) {
    hideLoading()
    handleApiError(error, 'Error al verificar empresa')
  }
}

// Abrir panel de busqueda de empresas
const abrirBuscadorEmpresa = () => {
  mostrarPanelEmpresas.value = true
  busquedaEmpresa.value = ''
  empresasEncontradas.value = []
  busquedaRealizada.value = false
}

// Cerrar panel de empresas
const cerrarPanelEmpresas = () => {
  mostrarPanelEmpresas.value = false
}

// Buscar empresas por nombre
const buscarEmpresas = async () => {
  if (!busquedaEmpresa.value.trim()) {
    showToast('Ingrese un nombre para buscar', 'warning')
    return
  }

  showLoading()
  try {
    const params = [
      { nombre: 'p_nombre', valor: busquedaEmpresa.value.trim(), tipo: 'string' }
    ]
    const data = await execute('sp_aseo_buscar_empresas_nombre', BASE_DB, params, '', null, SCHEMA)
    empresasEncontradas.value = data || []
    busquedaRealizada.value = true
  } catch (error) {
    hideLoading()
    handleApiError(error, 'Error al buscar empresas')
  } finally {
    hideLoading()
  }
}

// Seleccionar empresa del panel
const seleccionarEmpresa = (emp) => {
  formData.value.num_empresa = emp.num_empresa
  empresaInfo.value = {
    nombre: emp.descripcion || '',
    representante: emp.representante || ''
  }
  cerrarPanelEmpresas()
}

// Crear nueva empresa
const crearNuevaEmpresa = async () => {
  if (!busquedaEmpresa.value.trim()) {
    showToast('Ingrese un nombre para la nueva empresa', 'warning')
    return
  }

  const confirm = await Swal.fire({
    title: 'Crear Nueva Empresa',
    text: `Se creara la empresa: "${busquedaEmpresa.value}"`,
    icon: 'question',
    showCancelButton: true,
    confirmButtonText: 'Si, crear',
    cancelButtonText: 'Cancelar'
  })

  if (!confirm.isConfirmed) return

  showLoading()
  try {
    const params = [
      { nombre: 'p_nombre', valor: busquedaEmpresa.value.trim(), tipo: 'string' }
    ]
    const data = await execute('sp_aseo_crear_empresa_nueva', BASE_DB, params, '', null, SCHEMA)

    hideLoading()

    if (data && data.length > 0 && data[0].success) {
      await Swal.fire({
        title: 'Empresa Creada',
        text: `Numero de empresa: ${data[0].num_empresa}`,
        icon: 'success'
      })

      formData.value.num_empresa = data[0].num_empresa
      empresaInfo.value = {
        nombre: busquedaEmpresa.value.trim(),
        representante: busquedaEmpresa.value.trim()
      }
      cerrarPanelEmpresas()
    } else {
      showToast(data?.[0]?.mensaje || 'Error al crear empresa', 'error')
    }
  } catch (error) {
    hideLoading()
    hideLoading()
    handleApiError(error, 'Error al crear empresa')
  }
}

// Ejecutar alta de contrato
const ejecutar = async () => {
  // Validaciones basicas como en Delphi
  if (!formData.value.num_contrato || formData.value.num_contrato === 0) {
    showToast('Falta el dato del contrato, INTENTA DE NUEVO', 'warning')
    return
  }

  if (!formData.value.num_empresa || formData.value.num_empresa === 0) {
    showToast('Falta el dato de la empresa, INTENTA DE NUEVO', 'warning')
    return
  }

  if (!formData.value.cantidad || formData.value.cantidad === 0) {
    showToast('Falta la cantidad de recoleccion, INTENTA DE NUEVO', 'warning')
    return
  }

  if (!formData.value.domicilio.trim()) {
    showToast('Falta el domicilio de recoleccion, INTENTA DE NUEVO', 'warning')
    return
  }

  if (!formData.value.anio || formData.value.anio === 0) {
    showToast('Falta el dato del anio, INTENTA DE NUEVO', 'warning')
    return
  }

  if (formData.value.anio < 1989 || formData.value.anio > ejercicioActual) {
    showToast('No. Contrato, No. Empresa, Cant. de Recolec o Periodo son INCORRECTOS, INTENTA DE NUEVO', 'warning')
    return
  }

  showLoading()
  try {
    // Paso 1: Verificar empresa y contrato
    const paramsVerif = [
      { nombre: 'p_num_contrato', valor: formData.value.num_contrato, tipo: 'integer' },
      { nombre: 'p_num_empresa', valor: formData.value.num_empresa, tipo: 'integer' },
      { nombre: 'p_ctrol_aseo', valor: formData.value.ctrol_aseo, tipo: 'integer' }
    ]
    const verificacion = await execute('sp_aseo_verificar_contrato_empresa', BASE_DB, paramsVerif, '', null, SCHEMA)

    if (!verificacion || verificacion.length === 0) {
      hideLoading()
      showToast('Error al verificar datos', 'error')
      return
    }

    const verif = verificacion[0]
    if (!verif.valido) {
      hideLoading()
      await Swal.fire({
        title: 'Error',
        text: verif.mensaje || 'El dato de la empresa no existe o El Contrato ya existe, intenta con otro',
        icon: 'error'
      })
      return
    }

    // Paso 2: Crear el contrato
    // Obtener cve_recolec de la unidad seleccionada
    const unidadSel = unidadesRecolec.value.find(u => u.ctrol_recolec === formData.value.ctrol_recolec)
    const cveRecolec = unidadSel ? unidadSel.cve_recolec : ''

    const paramsContrato = [
      { nombre: 'p_num_contrato', valor: formData.value.num_contrato, tipo: 'integer' },
      { nombre: 'p_ctrol_aseo', valor: formData.value.ctrol_aseo, tipo: 'integer' },
      { nombre: 'p_num_empresa', valor: formData.value.num_empresa, tipo: 'integer' },
      { nombre: 'p_ctrol_emp', valor: 9, tipo: 'integer' }, // Siempre 9 (privadas)
      { nombre: 'p_ctrol_recolec', valor: formData.value.ctrol_recolec, tipo: 'integer' },
      { nombre: 'p_cantidad_recolec', valor: formData.value.cantidad, tipo: 'integer' },
      { nombre: 'p_domicilio', valor: formData.value.domicilio, tipo: 'string' },
      { nombre: 'p_sector', valor: formData.value.sector, tipo: 'string' },
      { nombre: 'p_ctrol_zona', valor: formData.value.ctrol_zona, tipo: 'integer' },
      { nombre: 'p_id_rec', valor: formData.value.id_rec, tipo: 'integer' },
      { nombre: 'p_fecha_oblig', valor: `${formData.value.anio}-${String(formData.value.mes).padStart(2, '0')}-01`, tipo: 'string' },
      { nombre: 'p_usuario', valor: 1, tipo: 'integer' } // TODO: obtener usuario real
    ]

    const resultContrato = await execute('sp_aseo_crear_contrato', BASE_DB, paramsContrato, '', null, SCHEMA)

    if (!resultContrato || resultContrato.length === 0 || !resultContrato[0].success) {
      hideLoading()
      await Swal.fire({
        title: 'Error',
        text: resultContrato?.[0]?.mensaje || 'No ejecuto correctamente la creacion del CONTRATO',
        icon: 'error'
      })
      return
    }

    const controlContrato = resultContrato[0].control_contrato

    // Paso 3: Generar pagos
    const paramsPagos = [
      { nombre: 'p_control_contrato', valor: controlContrato, tipo: 'integer' },
      { nombre: 'p_ejercicio', valor: formData.value.anio, tipo: 'integer' },
      { nombre: 'p_cve_recolec', valor: cveRecolec, tipo: 'string' },
      { nombre: 'p_cantidad', valor: formData.value.cantidad, tipo: 'integer' },
      { nombre: 'p_mes_inicio', valor: formData.value.mes, tipo: 'integer' },
      { nombre: 'p_usuario', valor: 1, tipo: 'integer' }
    ]

    const resultPagos = await execute('sp_aseo_generar_pagos_contrato', BASE_DB, paramsPagos, '', null, SCHEMA)

    hideLoading()

    if (resultPagos && resultPagos.length > 0 && resultPagos[0].success) {
      await Swal.fire({
        title: 'Contrato Creado',
        html: `<p>Contrato: <strong>${formData.value.num_contrato}</strong></p>
               <p>Control: <strong>${controlContrato}</strong></p>
               <p>${resultPagos[0].mensaje}</p>`,
        icon: 'success'
      })
      cancelar()
    } else {
      showToast('Error en insertar PAGOS DEL CONTRATO', 'warning')
    }

  } catch (error) {
    hideLoading()
    hideLoading()
    handleApiError(error, 'Error al crear contrato')
  }
}

// Cancelar
const cancelar = () => {
  router.push('/aseo-contratado')
}

// Inicializar
onMounted(async () => {
  showLoading()
  try {
    await Promise.all([
      cargarTiposAseo(),
      cargarZonas(),
      cargarRecaudadoras(),
      cargarUnidadesRecolec()
    ])
  } catch (error) {
    hideLoading()
    handleApiError(error, 'Error al cargar datos iniciales')
  } finally {
    hideLoading()
  }
})
</script>

