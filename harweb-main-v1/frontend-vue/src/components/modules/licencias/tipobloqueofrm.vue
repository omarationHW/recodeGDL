<template>
  <div class="tipobloqueo-page">
    <nav aria-label="breadcrumb" class="mb-3">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">Tipos de Bloqueo</li>
      </ol>
    </nav>
    
    <!-- Header con botones de nuevo y actualizar -->
    <div class="d-flex justify-content-between align-items-center mb-3">
      <h4>Catálogo de Tipos de Bloqueo</h4>
      <div class="btn-group">
        <button class="btn btn-success" @click="actualizarDatos()" :disabled="loading" title="Actualizar datos">
          <span v-if="loading" class="spinner-border spinner-border-sm me-2"></span>
          <i class="fas fa-sync-alt" :class="{ 'fa-spin': loading }"></i> Actualizar
        </button>
        <button class="btn btn-primary" @click="mostrarModalAgregar()">
          <i class="fas fa-plus"></i> Nuevo Tipo
        </button>
      </div>
    </div>

    <!-- Tabla de tipos de bloqueo -->
    <div class="card">
      <div class="card-body">
        <div class="table-responsive">
          <table class="table table-striped table-hover">
            <thead class="thead-light">
              <tr>
                <th>ID</th>
                <th>Descripción</th>
                <th>Estado</th>
                <th>Acciones</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="tipo in tiposBloqueo" :key="tipo.id">
                <td>{{ tipo.id }}</td>
                <td>{{ tipo.descripcion }}</td>
                <td>
                  <span :class="{'badge badge-success': tipo.sel_cons === 'S', 'badge badge-secondary': tipo.sel_cons === 'N'}">
                    {{ tipo.sel_cons === 'S' ? 'Activo' : 'Inactivo' }}
                  </span>
                </td>
                <td>
                  <div class="btn-group btn-group-sm">
                    <button class="btn btn-outline-primary" @click="editTipo(tipo)" title="Editar">
                      <i class="fas fa-edit"></i>
                    </button>
                    <button class="btn btn-outline-danger" @click="deleteTipo(tipo)" title="Eliminar">
                      <i class="fas fa-trash"></i>
                    </button>
                  </div>
                </td>
              </tr>
            </tbody>
          </table>
        </div>
        
        <div v-if="loading" class="text-center py-3">
          <div class="spinner-border" role="status">
            <span class="sr-only">Cargando...</span>
          </div>
        </div>
        
        <div v-if="!loading && tiposBloqueo.length === 0" class="text-center py-3">
          <p class="text-muted">No hay tipos de bloqueo registrados</p>
        </div>
      </div>
    </div>

    <!-- Modal para crear/editar -->
    <div v-if="showFormModal" class="modal fade show d-block" tabindex="-1" style="background: rgba(0,0,0,0.5)">
      <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content">
          <div class="modal-header">
            <h5 class="modal-title">{{ isEditing ? 'Editar' : 'Nuevo' }} Tipo de Bloqueo</h5>
            <button type="button" class="close" @click="cerrarModalFormulario()">
              <span>&times;</span>
            </button>
          </div>
          <form @submit.prevent="submitForm">
            <div class="modal-body">
              <div class="form-group">
                <label for="descripcion">Descripción <span class="text-danger">*</span></label>
                <input
                  id="descripcion"
                  v-model="form.descripcion"
                  type="text"
                  class="form-control"
                  :class="{'is-invalid': errors.descripcion}"
                  maxlength="100"
                  style="text-transform:uppercase"
                  required
                />
                <div v-if="errors.descripcion" class="invalid-feedback">
                  {{ errors.descripcion }}
                </div>
              </div>
              
              <div class="form-group">
                <label for="sel_cons">Estado</label>
                <select v-model="form.sel_cons" id="sel_cons" class="form-control">
                  <option value="S">Activo</option>
                  <option value="N">Inactivo</option>
                </select>
              </div>
            </div>
            
            <div class="modal-footer">
              <button type="button" class="btn btn-secondary" @click="cerrarModalFormulario()">Cancelar</button>
              <button type="submit" class="btn btn-primary" :disabled="submitting">
                <span v-if="submitting" class="spinner-border spinner-border-sm mr-2"></span>
                {{ isEditing ? 'Actualizar' : 'Crear' }}
              </button>
            </div>
          </form>
        </div>
      </div>
    </div>

    <!-- Mensajes de alerta -->
    <div v-if="message" :class="{'alert': true, 'alert-success': success, 'alert-danger': !success}" class="mt-3">
      {{ message }}
    </div>
  </div>
</template>

<script>
export default {
  name: 'TipoBloqueoGeneric',
  data() {
    return {
      tiposBloqueo: [],
      loading: false,
      submitting: false,
      isEditing: false,
      showFormModal: false,
      form: {
        id: null,
        descripcion: '',
        sel_cons: 'S'
      },
      errors: {},
      message: '',
      success: false
    };
  },
  mounted() {
    this.fetchTiposBloqueo();
  },
  methods: {
    // Cargar todos los tipos de bloqueo usando SP_TIPOBLOQUEO_LIST
    async fetchTiposBloqueo() {
      this.loading = true;
      this.clearMessage();
      try {
        const eRequest = {
          Operacion: 'sp_tipobloqueo_list',
          Base: 'licencias',
          Parametros: [], // Sin parámetros
          Tenant: 'guadalajara'
        };
        
        console.log('🚀 Cargando tipos de bloqueo desde la API usando TIPOBLOQUEO_LIST');

        const response = await fetch('http://localhost:8000/api/generic', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json'
          },
          body: JSON.stringify(eRequest)
        });
        const data = await response.json();
        
        if (data.eResponse && data.eResponse.success) {
          const apiData = data.eResponse.data.result || [];
          this.tiposBloqueo = apiData;
          console.log(`✅ ${this.tiposBloqueo.length} tipos de bloqueo cargados desde la API`);
        } else {
          throw new Error('API no devolvió datos válidos');
        }
      } catch (error) {
        console.error('❌ Error loading tipos bloqueo:', error);
        this.tiposBloqueo = [];
        this.showMessage('Error de conexión al cargar tipos de bloqueo', false);
      } finally {
        this.loading = false;
      }
    },

    // Editar tipo existente
    editTipo(tipo) {
      console.log('✏️ Editar tipo de bloqueo:', tipo);
      this.isEditing = true;
      this.form = {
        id: tipo.id,
        descripcion: tipo.descripcion,
        sel_cons: tipo.sel_cons
      };
      this.showFormModal = true;
    },

    // Enviar formulario (crear o actualizar)
    async submitForm() {
      this.clearErrors();
      this.clearMessage();
      
      if (!this.validateForm()) {
        return;
      }
      
      this.submitting = true;
      
      try {
        let eRequest;
        
        if (this.isEditing) {
          // Usar TIPOBLOQUEO_UPDATE para actualizar (SP_ se agrega en backend)
          eRequest = {
            Operacion: 'sp_tipobloqueo_update',
            Base: 'licencias',
            Parametros: [
              { nombre: 'p_id', valor: this.form.id, tipo: 'integer' },
              { nombre: 'p_descripcion', valor: this.form.descripcion.trim(), tipo: 'string' },
              { nombre: 'p_sel_cons', valor: this.form.sel_cons, tipo: 'string' }
            ],
            Tenant: 'guadalajara'
          };
        } else {
          // Usar TIPOBLOQUEO_CREATE para crear nuevo (SP_ se agrega en backend)
          eRequest = {
            Operacion: 'sp_tipobloqueo_create',
            Base: 'licencias',
            Parametros: [
              { nombre: 'p_descripcion', valor: this.form.descripcion.trim(), tipo: 'string' },
              { nombre: 'p_sel_cons', valor: this.form.sel_cons, tipo: 'string' }
            ],
            Tenant: 'guadalajara'
          };
        }
        
        console.log(`🚀 ${this.isEditing ? 'Actualizando' : 'Creando'} tipo de bloqueo usando ${eRequest.Operacion}`);
        console.log('📋 eRequest completo:', JSON.stringify(eRequest, null, 2));

        const response = await fetch('http://localhost:8000/api/generic', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json'
          },
          body: JSON.stringify(eRequest)
        });
        const data = await response.json();
        
        console.log('📋 Response recibida:', data);

        if (data.eResponse && data.eResponse.success) {
          console.log('✅ Tipo de bloqueo guardado correctamente');
          this.showMessage(
            this.isEditing ? 'Tipo de bloqueo actualizado correctamente' : 'Tipo de bloqueo creado correctamente',
            true
          );
          
          // Cerrar modal
          this.cerrarModalFormulario();
          
          // Recargar datos
          await this.fetchTiposBloqueo();
          
        } else {
          // Mostrar errores específicos del servidor
          const errorMsg = data.eResponse?.message || 'Error al procesar la solicitud';
          this.showMessage(errorMsg, false);
        }
        
      } catch (error) {
        console.error('❌ Error saving tipo bloqueo:', error);

        let errorMessage = 'Error desconocido';
        if (error.message) {
          errorMessage = error.message;
        }
        
        this.showMessage('Error al guardar tipo de bloqueo: ' + errorMessage, false);
      } finally {
        this.submitting = false;
      }
    },

    // Eliminar tipo de bloqueo usando SP_TIPOBLOQUEO_DELETE
    async deleteTipo(tipo) {
      console.log('🗑️ Eliminar tipo de bloqueo:', tipo);
      if (!confirm(`¿Está seguro de eliminar el tipo de bloqueo "${tipo.descripcion}"?`)) {
        return;
      }
      
      this.clearMessage();
      
      try {
        const eRequest = {
          Operacion: 'sp_tipobloqueo_delete',
          Base: 'licencias',
          Parametros: [
            { nombre: 'p_id', valor: tipo.id, tipo: 'integer' }
          ],
          Tenant: 'guadalajara'
        };
        
        console.log('🚀 Eliminando tipo de bloqueo usando TIPOBLOQUEO_DELETE:', tipo.id);

        const response = await fetch('http://localhost:8000/api/generic', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json'
          },
          body: JSON.stringify(eRequest)
        });
        const data = await response.json();
        
        if (data.eResponse && data.eResponse.success) {
          console.log('✅ Tipo de bloqueo eliminado correctamente');
          this.showMessage('Tipo de bloqueo eliminado correctamente', true);
          await this.fetchTiposBloqueo();
        } else {
          throw new Error(data.eResponse?.message || 'Error al eliminar tipo de bloqueo');
        }
        
      } catch (error) {
        console.error('❌ Error deleting tipo bloqueo:', error);
        this.showMessage('Error al eliminar tipo de bloqueo: ' + error.message, false);
      }
    },

    // Mostrar modal para agregar nuevo tipo
    mostrarModalAgregar() {
      console.log('➕ Mostrar modal agregar tipo de bloqueo');
      this.isEditing = false;
      this.resetearFormulario();
      this.showFormModal = true;
    },
    
    resetearFormulario() {
      this.form = {
        id: null,
        descripcion: '',
        sel_cons: 'S'
      };
      this.clearErrors();
    },

    cerrarModalFormulario() {
      this.showFormModal = false;
      this.isEditing = false;
      this.resetearFormulario();
    },

    async actualizarDatos() {
      console.log('🔄 Actualizando datos de tipos de bloqueo...');
      this.clearMessage();
      
      try {
        await this.fetchTiposBloqueo();
        this.showMessage('Datos actualizados correctamente', true);
      } catch (error) {
        console.error('❌ Error al actualizar datos:', error);
        this.showMessage('Error al actualizar los datos', false);
      }
    },

    // Validar formulario
    validateForm() {
      this.clearErrors();
      
      if (!this.form.descripcion || !this.form.descripcion.trim()) {
        this.errors.descripcion = 'La descripción es requerida';
        return false;
      }
      
      if (this.form.descripcion.trim().length < 3) {
        this.errors.descripcion = 'La descripción debe tener al menos 3 caracteres';
        return false;
      }
      
      return true;
    },

    // Utilidades
    showMessage(message, success) {
      this.message = message;
      this.success = success;
      // Auto-hide message after 5 seconds
      setTimeout(() => {
        this.clearMessage();
      }, 5000);
    },

    clearMessage() {
      this.message = '';
      this.success = false;
    },

    clearErrors() {
      this.errors = {};
    }
  }
};
</script>

<style scoped>
.tipobloqueo-page {
  max-width: 1200px;
  margin: 0 auto;
  padding: 20px;
}

.table th {
  background-color: #f8f9fa;
  font-weight: 600;
}

.btn-group .btn {
  margin-right: 2px;
}

.btn-group .btn:not(:last-child) {
  margin-right: 5px;
}

.fa-spin {
  animation: spin 1s linear infinite;
}

@keyframes spin {
  from { transform: rotate(0deg); }
  to { transform: rotate(360deg); }
}

.badge {
  font-size: 0.8rem;
}

.modal-header {
  background-color: #f8f9fa;
  border-bottom: 1px solid #dee2e6;
}

.invalid-feedback {
  display: block;
}

.spinner-border-sm {
  width: 1rem;
  height: 1rem;
}

@media (max-width: 768px) {
  .tipobloqueo-page {
    padding: 10px;
  }
  
  .table-responsive {
    font-size: 0.9rem;
  }
  
  .btn-group .btn {
    padding: 0.25rem 0.5rem;
  }
}
</style>
