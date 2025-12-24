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
      <button type="button" class="btn-help-icon" @click="openDocumentation" title="Ayuda">
        <font-awesome-icon icon="question-circle" />
      </button>
    </div>

    <div class="module-view-content">
      <form @submit.prevent="guardarContrato">
        <!-- Información de la Empresa -->
        <div class="municipal-card">
          <div class="municipal-card-header">
            <h5><font-awesome-icon icon="building" /> Información de la Empresa</h5>
          </div>
          <div class="municipal-card-body">
            <div class="form-row">
              <div class="form-group">
                <label class="municipal-form-label required">Empresa</label>
                <div class="input-group">
                  <select v-model="formData.num_empresa" class="municipal-form-control" required @change="cargarInfoEmpresa">
                    <option value="">Seleccione una empresa...</option>
                    <option v-for="empresa in empresas" :key="empresa.num_emp" :value="empresa.num_emp">
                      {{ empresa.nom_emp }}
                    </option>
                  </select>
                  <button type="button" class="btn-municipal-secondary" @click="abrirBuscadorEmpresa">
                    <font-awesome-icon icon="search" />
                  </button>
                </div>
              </div>
              <div class="form-group" v-if="empresaSeleccionada">
                <label class="municipal-form-label">Representante</label>
                <input type="text" :value="empresaSeleccionada.representante" class="municipal-form-control" readonly />
              </div>
            </div>
          </div>
        </div>

        <!-- Información del Domicilio -->
        <div class="municipal-card mt-3">
          <div class="municipal-card-header">
            <h5><font-awesome-icon icon="map-marker-alt" /> Domicilio del Servicio</h5>
          </div>
          <div class="municipal-card-body">
            <div class="form-row">
              <div class="form-group">
                <label class="municipal-form-label required">Calle</label>
                <input type="text" v-model="formData.calle" class="municipal-form-control" required maxlength="100" />
              </div>
              <div class="form-group">
                <label class="municipal-form-label required">Número Exterior</label>
                <input type="text" v-model="formData.numext" class="municipal-form-control" required maxlength="10" />
              </div>
              <div class="form-group">
                <label class="municipal-form-label">Número Interior</label>
                <input type="text" v-model="formData.numint" class="municipal-form-control" maxlength="10" />
              </div>
            </div>

            <div class="form-row">
              <div class="form-group">
                <label class="municipal-form-label required">Colonia</label>
                <input type="text" v-model="formData.colonia" class="municipal-form-control" required maxlength="100" />
              </div>
              <div class="form-group">
                <label class="municipal-form-label">Sector</label>
                <input type="text" v-model="formData.sector" class="municipal-form-control" maxlength="50" />
              </div>
              <div class="form-group">
                <label class="municipal-form-label">Código Postal</label>
                <input type="text" v-model="formData.cp" class="municipal-form-control" maxlength="5" pattern="[0-9]{5}" />
              </div>
            </div>

            <div class="form-row">
              <div class="form-group">
                <label class="municipal-form-label required">Municipio</label>
                <input type="text" v-model="formData.municipio" class="municipal-form-control" required maxlength="100" />
              </div>
              <div class="form-group">
                <label class="municipal-form-label required">Estado</label>
                <input type="text" v-model="formData.estado" class="municipal-form-control" required maxlength="50" />
              </div>
            </div>
          </div>
        </div>

        <!-- Información del Contrato -->
        <div class="municipal-card mt-3">
          <div class="municipal-card-header">
            <h5><font-awesome-icon icon="file-contract" /> Datos del Contrato</h5>
          </div>
          <div class="municipal-card-body">
            <div class="form-row">
              <div class="form-group">
                <label class="municipal-form-label">Número de Contrato</label>
                <input type="number" v-model="formData.num_contrato" class="municipal-form-control"
                  placeholder="Dejar vacío para auto-generar" />
                <small class="form-text">Si se deja vacío, se generará automáticamente</small>
              </div>
              <div class="form-group">
                <label class="municipal-form-label required">Tipo de Aseo</label>
                <select v-model="formData.tipo_aseo" class="municipal-form-control" required>
                  <option value="">Seleccione...</option>
                  <option v-for="tipo in tiposAseo" :key="tipo.tipo_aseo" :value="tipo.tipo_aseo">
                    {{ tipo.descripcion }}
                  </option>
                </select>
              </div>
            </div>

            <div class="form-row">
              <div class="form-group">
                <label class="municipal-form-label required">Unidad de Recolección</label>
                <select v-model="formData.cve_recoleccion" class="municipal-form-control" required>
                  <option value="">Seleccione...</option>
                  <option v-for="unidad in unidadesRecoleccion" :key="unidad.cve_recolec" :value="unidad.cve_recolec">
                    {{ unidad.descripcion }}
                  </option>
                </select>
              </div>
              <div class="form-group">
                <label class="municipal-form-label required">Cantidad de Unidades</label>
                <input type="number" v-model="formData.cantidad_recoleccion" class="municipal-form-control"
                  required min="1" />
              </div>
            </div>

            <div class="form-row">
              <div class="form-group">
                <label class="municipal-form-label required">Inicio de Obligación</label>
                <input type="month" v-model="formData.inicio_oblig" class="municipal-form-control" required />
              </div>
              <div class="form-group">
                <label class="municipal-form-label">Fin de Obligación</label>
                <input type="month" v-model="formData.fin_oblig" class="municipal-form-control" />
                <small class="form-text">Dejar vacío si es indefinido</small>
              </div>
            </div>

            <div class="form-row">
              <div class="form-group">
                <label class="municipal-form-label">RFC</label>
                <input type="text" v-model="formData.rfc" class="municipal-form-control" maxlength="13" />
              </div>
              <div class="form-group">
                <label class="municipal-form-label">CURP</label>
                <input type="text" v-model="formData.curp" class="municipal-form-control" maxlength="18" />
              </div>
            </div>
          </div>
        </div>

        <!-- Botones de Acción -->
        <div class="municipal-card mt-3">
          <div class="municipal-card-body">
            <div class="button-group">
              <button type="submit" class="btn-municipal-primary" :disabled="loading || !isFormValid">
                <font-awesome-icon :icon="loading ? 'spinner' : 'save'" :spin="loading" />
                {{ loading ? 'Guardando...' : 'Guardar Contrato' }}
              </button>
              <button type="button" class="btn-municipal-secondary" @click="limpiarFormulario" :disabled="loading">
                <font-awesome-icon icon="eraser" /> Limpiar
              </button>
              <button type="button" class="btn-municipal-secondary" @click="cancelar" :disabled="loading">
                <font-awesome-icon icon="times" /> Cancelar
              </button>
            </div>
          </div>
        </div>
      </form>
    </div>

    <DocumentationModal :show="showDocumentation" @close="showDocumentation = false" title="Ayuda - Alta de Contratos">
      <h3>Alta de Contratos</h3>
      <p>Este módulo permite registrar nuevos contratos de aseo contratado en el sistema.</p>

      <h4>Pasos para Registrar un Contrato:</h4>
      <ol>
        <li>Seleccione la empresa que contratará el servicio</li>
        <li>Complete la información del domicilio donde se prestará el servicio</li>
        <li>Especifique el tipo de aseo y las unidades de recolección</li>
        <li>Defina el periodo de vigencia del contrato</li>
        <li>Opcionalmente, ingrese RFC y CURP</li>
        <li>Guarde el contrato</li>
      </ol>

      <h4>Campos Importantes:</h4>
      <ul>
        <li><strong>Empresa:</strong> Empresa que solicita el servicio (requerido)</li>
        <li><strong>Tipo de Aseo:</strong> Categoría del servicio contratado</li>
        <li><strong>Unidades de Recolección:</strong> Tipo y cantidad de unidades</li>
        <li><strong>Inicio de Obligación:</strong> Fecha de inicio del servicio</li>
        <li><strong>Fin de Obligación:</strong> Fecha de término (opcional, puede ser indefinido)</li>
      </ul>

      <h4>Notas:</h4>
      <ul>
        <li>El número de contrato se genera automáticamente si no se especifica</li>
        <li>Todos los contratos nuevos se crean con status "Nuevo" (N)</li>
        <li>La información del domicilio es obligatoria</li>
        <li>Se recomienda capturar RFC y CURP para facturación</li>
      </ul>
    </DocumentationModal>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import DocumentationModal from '@/components/common/DocumentationModal.vue'
import { useApi } from '@/composables/useApi'
import { useLicenciasErrorHandler } from '@/composables/useLicenciasErrorHandler'
import Swal from 'sweetalert2'

const { execute } = useApi()
const { showToast } = useLicenciasErrorHandler()
const router = useRouter()

const loading = ref(false)
const showDocumentation = ref(false)
const empresas = ref([])
const empresaSeleccionada = ref(null)
const tiposAseo = ref([])
const unidadesRecoleccion = ref([])

const formData = ref({
  num_contrato: null,
  num_empresa: '',
  tipo_aseo: '',
  cve_recoleccion: '',
  cantidad_recoleccion: 1,
  calle: '',
  numext: '',
  numint: '',
  colonia: '',
  sector: '',
  cp: '',
  municipio: 'Guadalajara',
  estado: 'Jalisco',
  rfc: '',
  curp: '',
  inicio_oblig: '',
  fin_oblig: '',
  status_contrato: 'N' // Nuevo
})

const isFormValid = computed(() => {
  return formData.value.num_empresa &&
         formData.value.tipo_aseo &&
         formData.value.cve_recoleccion &&
         formData.value.cantidad_recoleccion > 0 &&
         formData.value.calle &&
         formData.value.numext &&
         formData.value.colonia &&
         formData.value.municipio &&
         formData.value.estado &&
         formData.value.inicio_oblig
})

const cargarEmpresas = async () => {
  try {
    const response = await execute('SP_ASEO_EMPRESAS_LIST', 'aseo_contratado', {
      p_page: 1,
      p_limit: 1000,
      p_search: null
    })

    if (response && response.data) {
      empresas.value = response.data
    }
  } catch (error) {
    console.error('Error al cargar empresas:', error)
  }
}

const cargarInfoEmpresa = () => {
  if (formData.value.num_empresa) {
    empresaSeleccionada.value = empresas.value.find(e => e.num_emp === formData.value.num_empresa)
  } else {
    empresaSeleccionada.value = null
  }
}

const cargarTiposAseo = async () => {
  try {
    const response = await execute('SP_ASEO_TIPOS_LIST', 'aseo_contratado', {
      p_page: 1,
      p_limit: 100,
      p_search: null
    })

    if (response && response.data) {
      tiposAseo.value = response.data
    }
  } catch (error) {
    console.error('Error al cargar tipos de aseo:', error)
  }
}

const cargarUnidadesRecoleccion = async () => {
  try {
    const response = await execute('SP_ASEO_UNIDADES_LIST', 'aseo_contratado', {
      p_page: 1,
      p_limit: 100,
      p_search: null
    })

    if (response && response.data) {
      unidadesRecoleccion.value = response.data
    }
  } catch (error) {
    console.error('Error al cargar unidades de recolección:', error)
  }
}

const guardarContrato = async () => {
  if (!isFormValid.value) {
    showToast('Complete todos los campos requeridos', 'warning')
    return
  }

  const result = await Swal.fire({
    title: '¿Guardar Contrato?',
    html: `<p>Empresa: <strong>${empresaSeleccionada.value?.nom_emp}</strong></p>
           <p>Domicilio: <strong>${formData.value.calle} ${formData.value.numext}</strong></p>`,
    icon: 'question',
    showCancelButton: true,
    confirmButtonText: 'Sí, guardar',
    cancelButtonText: 'Cancelar'
  })

  if (!result.isConfirmed) return

  loading.value = true

  try {
    // Convertir fechas a formato DATE (primer día del mes)
    const fechaInicio = formData.value.inicio_oblig ? `${formData.value.inicio_oblig}-01` : null
    const fechaFin = formData.value.fin_oblig ? `${formData.value.fin_oblig}-01` : null

    // Nota: Este SP debe ser creado - por ahora simulamos la estructura
    const response = await execute('SP_ASEO_CONTRATOS_CREATE', 'aseo_contratado', {
      p_num_contrato: formData.value.num_contrato || null,
      p_num_empresa: formData.value.num_empresa,
      p_tipo_aseo: formData.value.tipo_aseo,
      p_cve_recoleccion: formData.value.cve_recoleccion,
      p_cantidad_recoleccion: formData.value.cantidad_recoleccion,
      p_calle: formData.value.calle,
      p_numext: formData.value.numext,
      p_numint: formData.value.numint || null,
      p_colonia: formData.value.colonia,
      p_sector: formData.value.sector || null,
      p_cp: formData.value.cp || null,
      p_municipio: formData.value.municipio,
      p_estado: formData.value.estado,
      p_rfc: formData.value.rfc || null,
      p_curp: formData.value.curp || null,
      p_inicio_oblig: fechaInicio,
      p_fin_oblig: fechaFin,
      p_status_contrato: formData.value.status_contrato
    })

    if (response && response.data && response.data[0]) {
      const result = response.data[0]

      if (result.success) {
        await Swal.fire({
          title: '¡Éxito!',
          html: `<p>Contrato registrado exitosamente</p>
                 <p>Número de contrato: <strong>${result.num_contrato}</strong></p>`,
          icon: 'success',
          confirmButtonText: 'Aceptar'
        })

        limpiarFormulario()
      } else {
        showToast(result.message || 'Error al guardar el contrato', 'error')
      }
    }
  } catch (error) {
    console.error('Error:', error)
    showToast('Error al guardar el contrato', 'error')
  } finally {
    loading.value = false
  }
}

const limpiarFormulario = () => {
  formData.value = {
    num_contrato: null,
    num_empresa: '',
    tipo_aseo: '',
    cve_recoleccion: '',
    cantidad_recoleccion: 1,
    calle: '',
    numext: '',
    numint: '',
    colonia: '',
    sector: '',
    cp: '',
    municipio: 'Guadalajara',
    estado: 'Jalisco',
    rfc: '',
    curp: '',
    inicio_oblig: '',
    fin_oblig: '',
    status_contrato: 'N'
  }
  empresaSeleccionada.value = null
}

const cancelar = () => {
  router.push('/aseo-contratado')
}

const abrirBuscadorEmpresa = () => {
  showToast('Buscador de empresas en desarrollo', 'info')
}

const openDocumentation = () => {
  showDocumentation.value = true
}

onMounted(() => {
  cargarEmpresas()
  cargarTiposAseo()
  cargarUnidadesRecoleccion()
})
</script>
