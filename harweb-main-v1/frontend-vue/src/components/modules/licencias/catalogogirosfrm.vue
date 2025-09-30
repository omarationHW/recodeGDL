<template>
  <div class="container-fluid">
    <!-- Header -->
    <div class="row mb-4">
      <div class="col-12">
        <div class="d-flex justify-content-between align-items-center">
          <div>
            <h2 class="h4 mb-1">
              <i class="fas fa-list-alt me-2 text-primary"></i>
              Catálogo de Giros
            </h2>
            <p class="text-muted mb-0">Gestión y administración del catálogo de giros comerciales</p>
          </div>
          <nav aria-label="breadcrumb">
            <ol class="breadcrumb mb-0">
              <li class="breadcrumb-item">
                <router-link to="/dashboard" class="text-decoration-none">Dashboard</router-link>
              </li>
              <li class="breadcrumb-item">
                <router-link to="/licencias" class="text-decoration-none">Licencias</router-link>
              </li>
              <li class="breadcrumb-item active">Catálogo de Giros</li>
            </ol>
          </nav>
        </div>
      </div>
    </div>

    <!-- Filtros y búsqueda -->
    <div class="card mb-4">
      <div class="card-header">
        <h5 class="mb-0">
          <i class="fas fa-search me-2"></i>
          Búsqueda y Filtros
        </h5>
      </div>
      <div class="card-body">
        <div class="row g-3">
          <div class="col-md-4">
            <label for="busqueda" class="form-label">Buscar por descripción</label>
            <input
              type="text"
              class="form-control"
              id="busqueda"
              v-model="filtros.busqueda"
              placeholder="Ingrese descripción del giro"
              @input="filtrarGiros"
            >
          </div>
          <div class="col-md-3">
            <label for="estado" class="form-label">Estado</label>
            <select
              class="form-select"
              id="estado"
              v-model="filtros.estado"
              @change="filtrarGiros"
            >
              <option value="">Todos</option>
              <option value="S">Activos</option>
              <option value="N">Inactivos</option>
            </select>
          </div>
          <div class="col-md-3">
            <label for="categoria" class="form-label">Categoría</label>
            <select
              class="form-select"
              id="categoria"
              v-model="filtros.categoria"
              @change="filtrarGiros"
            >
              <option value="">Todas</option>
              <option
                v-for="categoria in categorias"
                :key="categoria.id"
                :value="categoria.id"
              >
                {{ categoria.nombre }}
              </option>
            </select>
          </div>
          <div class="col-md-2 d-flex align-items-end">
            <button
              type="button"
              class="btn btn-outline-secondary w-100"
              @click="limpiarFiltros"
            >
              <i class="fas fa-eraser me-2"></i>
              Limpiar
            </button>
          </div>
        </div>
      </div>
    </div>

    <!-- Acciones -->
    <div class="card mb-4">
      <div class="card-header">
        <h5 class="mb-0">
          <i class="fas fa-tools me-2"></i>
          Acciones
        </h5>
      </div>
      <div class="card-body">
        <div class="row g-2">
          <div class="col-md-6">
            <button
              type="button"
              class="btn btn-success w-100"
              @click="abrirModalNuevo"
            >
              <i class="fas fa-plus me-2"></i>
              Nuevo Giro
            </button>
          </div>
          <div class="col-md-6">
            <button
              type="button"
              class="btn btn-info w-100"
              @click="cargarGiros"
              :disabled="cargando"
            >
              <i class="fas fa-sync-alt me-2"></i>
              {{ cargando ? 'Cargando...' : 'Actualizar Lista' }}
            </button>
          </div>
        </div>
      </div>
    </div>

    <!-- Lista de giros -->
    <div class="card">
      <div class="card-header d-flex justify-content-between align-items-center">
        <h5 class="mb-0">
          <i class="fas fa-table me-2"></i>
          Lista de Giros ({{ girosFiltrados.length }})
        </h5>
        <div class="d-flex align-items-center gap-2">
          <span class="text-muted">Mostrando {{ girosFiltrados.length }} de {{ giros.length }}</span>
        </div>
      </div>
      <div class="card-body p-0">
        <div v-if="cargando" class="p-4 text-center">
          <div class="spinner-border text-primary me-2" role="status"></div>
          <span>Cargando giros...</span>
        </div>
        <div v-else-if="girosFiltrados.length === 0" class="p-4 text-center text-muted">
          <i class="fas fa-inbox me-2"></i>
          No se encontraron giros con los filtros aplicados
        </div>
        <div v-else class="table-responsive">
          <table class="table table-hover table-striped mb-0">
            <thead class="table-dark">
              <tr>
                <th>ID</th>
                <th>Código</th>
                <th>Descripción</th>
                <th>Categoría</th>
                <th>Estado</th>
                <th>Fecha Creación</th>
                <th>Acciones</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="giro in girosFiltrados" :key="giro.id">
                <td>{{ giro.id }}</td>
                <td>
                  <code>{{ giro.codigo }}</code>
                </td>
                <td>{{ giro.descripcion }}</td>
                <td>
                  <span class="badge bg-secondary">
                    {{ giro.categoria_nombre || 'Sin categoría' }}
                  </span>
                </td>
                <td>
                  <span class="badge" :class="giro.activo === 'S' ? 'bg-success' : 'bg-danger'">
                    {{ giro.activo === 'S' ? 'Activo' : 'Inactivo' }}
                  </span>
                </td>
                <td>{{ formatearFecha(giro.fecha_creacion) }}</td>
                <td>
                  <div class="btn-group btn-group-sm">
                    <button
                      type="button"
                      class="btn btn-outline-primary"
                      @click="editarGiro(giro)"
                      title="Editar"
                    >
                      <i class="fas fa-edit"></i>
                    </button>
                    <button
                      type="button"
                      class="btn btn-outline-warning"
                      @click="cambiarEstado(giro)"
                      :title="giro.activo === 'S' ? 'Desactivar' : 'Activar'"
                    >
                      <i class="fas" :class="giro.activo === 'S' ? 'fa-toggle-on' : 'fa-toggle-off'"></i>
                    </button>
                  </div>
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
    </div>

    <!-- Modal para nuevo/editar giro -->
    <div v-if="showModal" class="modal fade show d-block" tabindex="-1">
      <div class="modal-dialog modal-lg">
        <div class="modal-content">
          <div class="modal-header" :class="modoEdicion ? 'bg-warning text-dark' : 'bg-success text-white'">
            <h5 class="modal-title">
              <i class="fas me-2" :class="modoEdicion ? 'fa-edit' : 'fa-plus'"></i>
              {{ modoEdicion ? 'Editar Giro' : 'Nuevo Giro' }}
            </h5>
            <button type="button" class="btn-close" :class="modoEdicion ? '' : 'btn-close-white'" @click="cerrarModal"></button>
          </div>
          <div class="modal-body">
            <form @submit.prevent="guardarGiro">
              <div class="row g-3">
                <div class="col-md-6">
                  <label for="modalCodigo" class="form-label">Código *</label>
                  <input
                    type="text"
                    class="form-control"
                    id="modalCodigo"
                    v-model="formulario.codigo"
                    :readonly="modoEdicion"
                    placeholder="Código único del giro"
                    required
                  >
                </div>
                <div class="col-md-6">
                  <label for="modalCategoria" class="form-label">Categoría</label>
                  <select
                    class="form-select"
                    id="modalCategoria"
                    v-model="formulario.id_categoria"
                  >
                    <option value="">Sin categoría</option>
                    <option
                      v-for="categoria in categorias"
                      :key="categoria.id"
                      :value="categoria.id"
                    >
                      {{ categoria.nombre }}
                    </option>
                  </select>
                </div>
                <div class="col-12">
                  <label for="modalDescripcion" class="form-label">Descripción *</label>
                  <textarea
                    class="form-control"
                    id="modalDescripcion"
                    v-model="formulario.descripcion"
                    rows="3"
                    placeholder="Descripción detallada del giro"
                    required
                  ></textarea>
                </div>
                <div class="col-md-6">
                  <label for="modalActivo" class="form-label">Estado</label>
                  <select
                    class="form-select"
                    id="modalActivo"
                    v-model="formulario.activo"
                  >
                    <option value="S">Activo</option>
                    <option value="N">Inactivo</option>
                  </select>
                </div>
                <div class="col-md-6">
                  <label for="modalOrden" class="form-label">Orden</label>
                  <input
                    type="number"
                    class="form-control"
                    id="modalOrden"
                    v-model="formulario.orden"
                    min="0"
                    placeholder="Orden de aparición"
                  >
                </div>
              </div>
            </form>
          </div>
          <div class="modal-footer">
            <button
              type="button"
              class="btn btn-secondary"
              @click="cerrarModal"
              :disabled="guardando"
            >
              Cancelar
            </button>
            <button
              type="button"
              class="btn"
              :class="modoEdicion ? 'btn-warning' : 'btn-success'"
              @click="guardarGiro"
              :disabled="!formulario.codigo || !formulario.descripcion || guardando"
            >
              <i class="fas fa-spinner fa-spin me-2" v-if="guardando"></i>
              <i class="fas me-2" :class="modoEdicion ? 'fa-save' : 'fa-plus'" v-else></i>
              {{ guardando ? 'Guardando...' : (modoEdicion ? 'Actualizar' : 'Crear') }}
            </button>
          </div>
        </div>
      </div>
    </div>

    <!-- Modal backdrop -->
    <div v-if="showModal" class="modal-backdrop fade show"></div>

    <!-- Alertas -->
    <div v-if="mensaje" class="position-fixed top-0 end-0 p-3" style="z-index: 1060">
      <div class="toast show" role="alert">
        <div class="toast-header">
          <i class="fas me-2" :class="mensaje.tipo === 'success' ? 'fa-check-circle text-success' : 'fa-exclamation-triangle text-danger'"></i>
          <strong class="me-auto">{{ mensaje.tipo === 'success' ? 'Éxito' : 'Error' }}</strong>
          <button type="button" class="btn-close" @click="mensaje = null"></button>
        </div>
        <div class="toast-body">
          {{ mensaje.texto }}
        </div>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'CatalogoGirosfrm',
  data() {
    return {
      giros: [],
      girosFiltrados: [],
      categorias: [],
      filtros: {
        busqueda: '',
        estado: '',
        categoria: ''
      },
      formulario: {
        id: null,
        codigo: '',
        descripcion: '',
        id_categoria: '',
        activo: 'S',
        orden: 0
      },
      cargando: false,
      guardando: false,
      showModal: false,
      modoEdicion: false,
      mensaje: null
    }
  },

  async mounted() {
    await this.cargarCategorias()
    await this.cargarGiros()
  },

  methods: {
    async cargarGiros() {
      this.cargando = true
      try {
        const eRequest = {
          Operacion: 'sp_giros_listar',
          Base: 'licencias',
          Parametros: [],
          Tenant: 'guadalajara'
        }

        const response = await fetch('http://localhost:8000/api/generic', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json'
          },
          body: JSON.stringify(eRequest)
        });
        const data = await response.json();

        if (data.eResponse.success) {
          this.giros = data.eResponse.data.result || []
          this.filtrarGiros()
        } else {
          this.mostrarMensaje('error', 'Error al cargar los giros')
        }
      } catch (error) {
        console.error('Error cargando giros:', error)
        this.mostrarMensaje('error', 'Error al cargar los giros')
      } finally {
        this.cargando = false
      }
    },

    async cargarCategorias() {
      try {
        const eRequest = {
          Operacion: 'sp_categorias_giros_listar',
          Base: 'licencias',
          Parametros: [],
          Tenant: 'guadalajara'
        }

        const response = await fetch('http://localhost:8000/api/generic', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json'
          },
          body: JSON.stringify(eRequest)
        });
        const data = await response.json();

        if (data.eResponse.success) {
          this.categorias = data.eResponse.data.result || []
        }
      } catch (error) {
        console.error('Error cargando categorías:', error)
      }
    },

    filtrarGiros() {
      let resultado = [...this.giros]

      // Filtrar por búsqueda
      if (this.filtros.busqueda) {
        const busqueda = this.filtros.busqueda.toLowerCase()
        resultado = resultado.filter(giro =>
          giro.descripcion.toLowerCase().includes(busqueda) ||
          giro.codigo.toLowerCase().includes(busqueda)
        )
      }

      // Filtrar por estado
      if (this.filtros.estado) {
        resultado = resultado.filter(giro => giro.activo === this.filtros.estado)
      }

      // Filtrar por categoría
      if (this.filtros.categoria) {
        resultado = resultado.filter(giro => giro.id_categoria === parseInt(this.filtros.categoria))
      }

      this.girosFiltrados = resultado
    },

    limpiarFiltros() {
      this.filtros = {
        busqueda: '',
        estado: '',
        categoria: ''
      }
      this.filtrarGiros()
    },

    abrirModalNuevo() {
      this.modoEdicion = false
      this.formulario = {
        id: null,
        codigo: '',
        descripcion: '',
        id_categoria: '',
        activo: 'S',
        orden: 0
      }
      this.showModal = true
    },

    editarGiro(giro) {
      this.modoEdicion = true
      this.formulario = {
        id: giro.id,
        codigo: giro.codigo,
        descripcion: giro.descripcion,
        id_categoria: giro.id_categoria || '',
        activo: giro.activo,
        orden: giro.orden || 0
      }
      this.showModal = true
    },

    cerrarModal() {
      this.showModal = false
      this.modoEdicion = false
      this.formulario = {
        id: null,
        codigo: '',
        descripcion: '',
        id_categoria: '',
        activo: 'S',
        orden: 0
      }
    },

    async guardarGiro() {
      if (!this.formulario.codigo || !this.formulario.descripcion) return

      this.guardando = true
      try {
        const operacion = this.modoEdicion ? 'sp_giro_actualizar' : 'sp_giro_crear'
        const parametros = [
          { nombre: 'p_codigo', valor: this.formulario.codigo, tipo: 'varchar' },
          { nombre: 'p_descripcion', valor: this.formulario.descripcion, tipo: 'varchar' },
          { nombre: 'p_id_categoria', valor: this.formulario.id_categoria || null, tipo: 'integer' },
          { nombre: 'p_activo', valor: this.formulario.activo, tipo: 'char' },
          { nombre: 'p_orden', valor: this.formulario.orden, tipo: 'integer' },
          { nombre: 'p_usuario', valor: 'admin', tipo: 'varchar' }
        ]

        if (this.modoEdicion) {
          parametros.unshift({ nombre: 'p_id', valor: this.formulario.id, tipo: 'integer' })
        }

        const eRequest = {
          Operacion: operacion,
          Base: 'licencias',
          Parametros: parametros,
          Tenant: 'guadalajara'
        }

        const response = await fetch('http://localhost:8000/api/generic', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json'
          },
          body: JSON.stringify(eRequest)
        });
        const data = await response.json();

        if (data.eResponse.success && data.eResponse.data.result[0]?.success) {
          this.mostrarMensaje('success', data.eResponse.data.result[0].message)
          this.cerrarModal()
          await this.cargarGiros()
        } else {
          this.mostrarMensaje('error', data.eResponse.data.result[0]?.message || 'Error al guardar el giro')
        }
      } catch (error) {
        console.error('Error guardando giro:', error)
        this.mostrarMensaje('error', 'Error al guardar el giro')
      } finally {
        this.guardando = false
      }
    },

    async cambiarEstado(giro) {
      try {
        const nuevoEstado = giro.activo === 'S' ? 'N' : 'S'

        const eRequest = {
          Operacion: 'sp_giro_cambiar_estado',
          Base: 'licencias',
          Parametros: [
            { nombre: 'p_id', valor: giro.id, tipo: 'integer' },
            { nombre: 'p_activo', valor: nuevoEstado, tipo: 'char' },
            { nombre: 'p_usuario', valor: 'admin', tipo: 'varchar' }
          ],
          Tenant: 'guadalajara'
        }

        const response = await fetch('http://localhost:8000/api/generic', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json'
          },
          body: JSON.stringify(eRequest)
        });
        const data = await response.json();

        if (data.eResponse.success && data.eResponse.data.result[0]?.success) {
          this.mostrarMensaje('success', `Giro ${nuevoEstado === 'S' ? 'activado' : 'desactivado'} correctamente`)
          await this.cargarGiros()
        } else {
          this.mostrarMensaje('error', data.eResponse.data.result[0]?.message || 'Error al cambiar estado')
        }
      } catch (error) {
        console.error('Error cambiando estado:', error)
        this.mostrarMensaje('error', 'Error al cambiar el estado del giro')
      }
    },

    formatearFecha(fecha) {
      if (!fecha) return 'N/A'
      return new Date(fecha).toLocaleDateString('es-MX')
    },

    mostrarMensaje(tipo, texto) {
      this.mensaje = { tipo, texto }
      setTimeout(() => {
        this.mensaje = null
      }, 5000)
    }
  }
}
</script>

<style scoped>
.toast {
  min-width: 300px;
}

.modal.show {
  display: block;
}

.modal-backdrop {
  position: fixed;
  top: 0;
  left: 0;
  z-index: 1040;
  width: 100vw;
  height: 100vh;
  background-color: #000;
  opacity: 0.5;
}

.table th {
  border-top: none;
}

.btn-group-sm > .btn {
  padding: 0.25rem 0.5rem;
  font-size: 0.875rem;
}

code {
  background-color: #f8f9fa;
  padding: 0.2rem 0.4rem;
  border-radius: 0.25rem;
  color: #d63384;
}
</style>