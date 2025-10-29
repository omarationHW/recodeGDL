<template>
  <div class="module-view">
    <!-- HEADER -->
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="store" />
      </div>
      <div class="module-view-info">
        <h1>Cat�logo de Giros Comerciales</h1>
        <p>Mercados - Gesti�n de giros y actividades comerciales</p>
      </div>
      <button class="btn-help-icon" @click="mostrarAyuda" type="button">
        <font-awesome-icon icon="question-circle" /> Ayuda
      </button>
    </div>

    <!-- ACCIONES -->
    <div class="municipal-card">
      <div >
        <div class="form-row">
          <button
            type="button"
            class="btn-municipal-success"
            @click="nuevoGiro"
            :disabled="cargando"
          >
            <font-awesome-icon icon="plus" /> Nuevo Giro
          </button>

          <button
            type="button"
            class="btn-municipal-info"
            @click="exportarExcel"
            :disabled="cargando || giros.length === 0"
          >
            <font-awesome-icon icon="file-excel" /> Exportar Excel
          </button>

          <button
            type="button"
            class="btn-municipal-primary"
            @click="cargarDatos"
            :disabled="cargando"
          >
            <font-awesome-icon icon="sync-alt" /> Actualizar
          </button>
        </div>
        </div>
    </div>

    <!-- ESTAD�STICAS -->
    <div v-if="giros.length > 0" class="municipal-card">
      <div class="stats-dashboard">
        <div class="stat-item stat-primary">
          <div class="stat-value">{{ giros.length }}</div>
          <div class="stat-label">Total Giros</div>
          <div class="stat-sublabel">Registrados</div>
        </div>

        <div class="stat-item stat-success">
          <div class="stat-value">{{ girosVigentes }}</div>
          <div class="stat-label">Giros Vigentes</div>
          <div class="stat-sublabel">Activos</div>
        </div>

        <div class="stat-item stat-danger">
          <div class="stat-value">{{ girosBaja }}</div>
          <div class="stat-label">Giros de Baja</div>
          <div class="stat-sublabel">Inactivos</div>
        </div>
      </div>
    </div>

    <!-- TABLA DE GIROS -->
    <div v-if="giros.length > 0" class="municipal-card">
      <div class="municipal-card-header">
        <h5><font-awesome-icon icon="table" /> Listado de Giros Comerciales</h5>
      </div>

      <div class="municipal-table">
        <table class="municipal-table">
          <thead>
            <tr>
              <th class="text-center">#</th>
              <th class="text-center">Clave</th>
              <th>Descripci�n</th>
              <th class="text-center">Vigencia</th>
              <th class="text-center">Acciones</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="(item, index) in giros" :key="item.id_giro">
              <td class="text-center">{{ index + 1 }}</td>
              <td class="text-center">
                <span class="badge-info">{{ item.cve_giro }}</span>
              </td>
              <td>{{ item.descripcion }}</td>
              <td class="text-center">
                <span class="badge item.vigencia === 'V' ? 'badge-success' : 'badge-danger'" :>
                  {{ item.vigencia === 'V' ? 'Vigente' : 'Baja' }}
                </span>
              </td>
              <td class="text-center">
                <button
                  type="button"
                  class="btn-icon btn-warning"
                  @click="editarGiro(item)"
                  title="Editar"
                >
                  <font-awesome-icon icon="edit" />
                </button>
                <button
                  type="button"
                  class="btn-icon btn-danger"
                  @click="eliminarGiro(item)"
                  title="Eliminar"
                >
                  <font-awesome-icon icon="trash" />
                </button>
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>

    <!-- SIN DATOS -->
    <div v-else-if="!cargando" class="municipal-card">
      <div class="alert alert-info">
        <font-awesome-icon icon="info-circle" />
        No hay giros comerciales registrados en el sistema.
      </div>
    </div>

    <!-- MODAL FORMULARIO -->
    <div v-if="mostrarFormulario" class="modal-overlay" @click.self="cerrarFormulario">
      <div class="modal-content">
        <div class="modal-header">
          <h2>
            <font-awesome-icon :icon="modoEdicion ? 'edit' : 'plus'" />
            {{ modoEdicion ? 'Editar' : 'Nuevo' }} Giro Comercial
          </h2>
          <button type="button" class="btn-close" @click="cerrarFormulario">&times;</button>
        </div>

        <form @submit.prevent="guardarGiro" >
          <div class="modal-body">
            <div class="form-row">
              <div class="form-group">
                <label for="cve-giro" class="municipal-form-label required">Clave del Giro:</label>
                <input
                  type="text"
                  v-model="formulario.cve_giro"
                  id="cve-giro"
                  class="municipal-form-control"
                  required
                  :disabled="guardando || modoEdicion"
                  maxlength="10"
                  placeholder="Ej: A001"
                />
                <small v-if="modoEdicion" class="form-text text-muted">
                  La clave no se puede modificar
                </small>
              </div>
        </div>

            <div class="form-row">
              <div class="form-group">
                <label for="descripcion" class="municipal-form-label required">Descripci�n:</label>
                <input
                  type="text"
                  v-model="formulario.descripcion"
                  id="descripcion"
                  class="municipal-form-control"
                  required
                  :disabled="guardando"
                  maxlength="100"
                  placeholder="Descripci�n del giro comercial"
                />
              </div>
        </div>

            <div class="form-row">
              <div class="form-group">
                <label for="vigencia" class="municipal-form-label required">Vigencia:</label>
                <select
                  v-model="formulario.vigencia"
                  id="vigencia"
                  class="municipal-form-control"
                  required
                  :disabled="guardando"
                >
                  <option value="">Seleccione...</option>
                  <option value="V">Vigente</option>
                  <option value="B">Baja</option>
                </select>
              </div>
        </div>
          </div>

          <div class="modal-footer">
            <button
              type="button"
              class="btn-municipal-secondary"
              @click="cerrarFormulario"
              :disabled="guardando"
            >
              <font-awesome-icon icon="times" /> Cancelar
            </button>
            <button
              type="submit"
              class="btn-municipal-success"
              :disabled="guardando"
            >
              <font-awesome-icon icon="save" /> Guardar
            </button>
          </div>
        </form>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { useApi } from '@/composables/useApi'
import { useLicenciasErrorHandler } from '@/composables/useLicenciasErrorHandler'
import { useToast } from '@/composables/useToast'
import Swal from 'sweetalert2'
import * as XLSX from 'xlsx'

const { execute } = useApi()
const { handleError } = useLicenciasErrorHandler()
const { showToast } = useToast()

// Estado
const cargando = ref(false)
const guardando = ref(false)
const mostrarFormulario = ref(false)
const modoEdicion = ref(false)
const giros = ref([])

// Formulario
const formulario = ref({
  id_giro: null,
  cve_giro: '',
  descripcion: '',
  vigencia: 'V'
})

// Computed
const girosVigentes = computed(() => {
  return giros.value.filter(g => g.vigencia === 'V').length
})

const girosBaja = computed(() => {
  return giros.value.filter(g => g.vigencia === 'B').length
})

// Cargar datos al montar
onMounted(() => {
  cargarDatos()
})

// Cargar giros
async function cargarDatos() {
  try {
    cargando.value = true
    const response = await execute('SP_MERCADOS_GIROS_LIST', 'mercados', {})
    giros.value = response || []
  } catch (error) {
    handleError(error)
  } finally {
    cargando.value = false
  }
}

// Nuevo giro
function nuevoGiro() {
  modoEdicion.value = false
  formulario.value = {
    id_giro: null,
    cve_giro: '',
    descripcion: '',
    vigencia: 'V'
  }
  mostrarFormulario.value = true
}

// Editar giro
function editarGiro(giro) {
  modoEdicion.value = true
  formulario.value = {
    id_giro: giro.id_giro,
    cve_giro: giro.cve_giro,
    descripcion: giro.descripcion,
    vigencia: giro.vigencia
  }
  mostrarFormulario.value = true
}

// Guardar giro
async function guardarGiro() {
  try {
    guardando.value = true

    if (modoEdicion.value) {
      await execute('SP_MERCADOS_GIROS_UPDATE', 'mercados', {
        p_id_giro: formulario.value.id_giro,
        p_descripcion: formulario.value.descripcion,
        p_vigencia: formulario.value.vigencia
      })
      showToast('Giro actualizado correctamente', 'success')
    } else {
      await execute('SP_MERCADOS_GIROS_CREATE', 'mercados', {
        p_cve_giro: formulario.value.cve_giro,
        p_descripcion: formulario.value.descripcion,
        p_vigencia: formulario.value.vigencia
      })
      showToast('Giro creado correctamente', 'success')
    }

    cerrarFormulario()
    await cargarDatos()

  } catch (error) {
    handleError(error)
  } finally {
    guardando.value = false
  }
}

// Eliminar giro
async function eliminarGiro(giro) {
  const result = await Swal.fire({
    title: '�Eliminar giro?',
    html: `�Est� seguro de eliminar el giro:<br>
           <strong>${giro.cve_giro} - ${giro.descripcion}</strong>?<br><br>
           <small class="text-danger">Esta acci�n no se puede deshacer y fallar� si hay locales asociados.</small>`,
    icon: 'warning',
    showCancelButton: true,
    confirmButtonText: 'S�, eliminar',
    cancelButtonText: 'Cancelar',
    confirmButtonColor: '#d33'
  })

  if (result.isConfirmed) {
    try {
      await execute('SP_MERCADOS_GIROS_DELETE', 'mercados', {
        p_id_giro: giro.id_giro
      })
      showToast('Giro eliminado correctamente', 'success')
      await cargarDatos()
    } catch (error) {
      handleError(error)
    }
  }
}

// Cerrar formulario
function cerrarFormulario() {
  mostrarFormulario.value = false
  modoEdicion.value = false
}

// Exportar a Excel
function exportarExcel() {
  try {
    const datos = giros.value.map((item, idx) => ({
      '#': idx + 1,
      'Clave': item.cve_giro,
      'Descripci�n': item.descripcion,
      'Vigencia': item.vigencia === 'V' ? 'Vigente' : 'Baja'
    }))

    const ws = XLSX.utils.json_to_sheet(datos)
    const wb = XLSX.utils.book_new()
    XLSX.utils.book_append_sheet(wb, ws, 'Giros')

    const nombreArchivo = `Giros_Comerciales_${new Date().toISOString().split('T')[0]}.xlsx`

    XLSX.writeFile(wb, nombreArchivo)
    showToast('Archivo Excel generado correctamente', 'success')
  } catch (error) {
    handleError(error)
  }
}

// Mostrar ayuda
function mostrarAyuda() {
  Swal.fire({
    title: 'Ayuda - Cat�logo de Giros Comerciales',
    html: `
      <div class="help-content" style="text-align: left;">
        <h3>Descripci�n</h3>
        <p>Este m�dulo permite gestionar el cat�logo de giros comerciales que se asignan a los locales en los mercados.</p>

        <h3>�Qu� son los Giros Comerciales?</h3>
        <p>Los giros comerciales son clasificaciones que identifican el tipo de actividad econ�mica que se realiza en un local. Ejemplos:</p>
        <ul>
          <li>Alimentos y bebidas</li>
          <li>Ropa y calzado</li>
          <li>Frutas y verduras</li>
          <li>Carnicer�a</li>
          <li>Abarrotes</li>
          <li>Artesan�as</li>
          <li>Servicios varios</li>
        </ul>

        <h3>Gesti�n de Giros</h3>
        <ul>
          <li><strong>Nuevo Giro:</strong> Permite registrar un nuevo giro con clave �nica</li>
          <li><strong>Editar:</strong> Modifica la descripci�n y vigencia de un giro existente</li>
          <li><strong>Eliminar:</strong> Elimina un giro del sistema (solo si no tiene locales asociados)</li>
          <li><strong>Actualizar:</strong> Recarga el listado desde la base de datos</li>
          <li><strong>Exportar Excel:</strong> Descarga el cat�logo completo en formato Excel</li>
        </ul>

        <h3>Campos del Giro</h3>
        <ul>
          <li><strong>Clave:</strong> C�digo �nico identificador del giro (no modificable una vez creado)</li>
          <li><strong>Descripci�n:</strong> Nombre descriptivo del giro comercial (m�ximo 100 caracteres)</li>
          <li><strong>Vigencia:</strong> Estado del giro (Vigente/Baja)</li>
        </ul>

        <h3>Validaciones</h3>
        <ul>
          <li>No se pueden crear dos giros con la misma clave</li>
          <li>Al editar, la clave no se puede modificar</li>
          <li>No se puede eliminar un giro que tenga locales asociados</li>
          <li>La descripci�n es obligatoria</li>
        </ul>

        <h3>Estad�sticas</h3>
        <ul>
          <li><strong>Total Giros:</strong> Cantidad total de giros registrados</li>
          <li><strong>Giros Vigentes:</strong> Cantidad de giros activos</li>
          <li><strong>Giros de Baja:</strong> Cantidad de giros inactivos</li>
        </ul>

        <h3>Uso en el Sistema</h3>
        <ul>
          <li>Los giros se asignan a los locales para identificar su actividad comercial</li>
          <li>Permiten generar reportes y estad�sticas por tipo de actividad</li>
          <li>Facilitan la aplicaci�n de tarifas y regulaciones espec�ficas por giro</li>
          <li>Son �tiles para planificaci�n y distribuci�n de espacios en mercados</li>
        </ul>

        <h3>Notas Importantes</h3>
        <ul>
          <li>Los giros son utilizados por los locales para clasificaci�n y reportes</li>
          <li>Dar de baja un giro no elimina los locales asociados, solo impide asignarlo a nuevos locales</li>
          <li>Se recomienda no eliminar giros, sino marcarlos como "Baja"</li>
          <li>Las claves deben ser �nicas y f�ciles de identificar</li>
        </ul>
      </div>
    `,
    icon: 'info',
    width: 800,
    confirmButtonText: 'Entendido'
  })
}
</script>


