<template>
  <div class="bloquear-anuncio-page">
    <nav aria-label="breadcrumb" class="mb-3">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">Bloqueo de Anuncios</li>
      </ol>
    </nav>
    <div class="municipal-header">
      <i class="fas fa-ban text-white me-2"></i>
      <h2>BLOQUEO DE ANUNCIOS</h2>
    </div>
    <div class="municipal-card mb-3">
      <div class="card-body">
        <form @submit.prevent="buscarAnuncio">
          <div class="row align-items-center">
            <div class="col-md-4">
              <label for="numero_anuncio">No. de anuncio:</label>
              <input v-model="numero_anuncio" id="numero_anuncio" type="text" class="form-control" required @keyup.enter="buscarAnuncio" />
            </div>
            <div class="col-md-2">
              <label>Estado:</label>
              <span :class="{'text-danger': anuncio && anuncio.bloqueado, 'text-success': anuncio && !anuncio.bloqueado}" style="font-weight:bold">
                {{ anuncio ? (anuncio.bloqueado ? 'BLOQUEADO' : 'NO BLOQUEADO') : '' }}
              </span>
            </div>
            <div class="col-md-2">
              <div class="btn-group municipal-group-btn mt-3" role="group">
                <button type="submit" class="btn btn-outline-primary">
                  <i class="fas fa-search me-1"></i>Buscar
                </button>
              </div>
            </div>
          </div>
        </form>
      </div>
    </div>
    <div v-if="anuncio" class="municipal-card mb-3">
      <div class="card-body">
        <div class="row mb-2">
          <div class="col-md-3"><strong>Licencia de referencia:</strong> {{ anuncio.id_licencia }}</div>
          <div class="col-md-3"><strong>Fecha de otorgamiento:</strong> {{ anuncio.fecha_otorgamiento }}</div>
        </div>
        <div class="row mb-2">
          <div class="col-md-2"><strong>Medidas:</strong> {{ anuncio.medidas1 }} por {{ anuncio.medidas2 }}</div>
          <div class="col-md-2"><strong>Área:</strong> {{ anuncio.area_anuncio }}</div>
        </div>
        <div class="row mb-2">
          <div class="col-md-4"><strong>Ubicación:</strong> {{ anuncio.ubicacion }}</div>
          <div class="col-md-2"><strong>No. ext.:</strong> {{ anuncio.numext_ubic }}</div>
          <div class="col-md-2"><strong>Letra ext.:</strong> {{ anuncio.letraext_ubic }}</div>
          <div class="col-md-2"><strong>No. int.:</strong> {{ anuncio.numint_ubic }}</div>
          <div class="col-md-2"><strong>Letra int.:</strong> {{ anuncio.letraint_ubic }}</div>
        </div>
      </div>
    </div>
    <div v-if="anuncio" class="mb-3">
      <div class="btn-group municipal-group-btn" role="group">
        <button class="btn btn-outline-danger" :disabled="anuncio.bloqueado" @click="bloquearDialog = true">
          <i class="fas fa-lock me-1"></i>Bloquear anuncio
        </button>
        <button class="btn btn-outline-success" :disabled="!anuncio.bloqueado" @click="desbloquearDialog = true">
          <i class="fas fa-unlock me-1"></i>Desbloquear anuncio
        </button>
      </div>
    </div>
    <div v-if="anuncio">
      <h5><i class="fas fa-history me-2"></i>Movimientos anteriores</h5>
      <table class="table table-sm municipal-table">
        <thead class="municipal-table-header">
          <tr>
            <th>Estado</th>
            <th>Realizó</th>
            <th>Fecha</th>
            <th>Motivo</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="bloqueo in bloqueos" :key="bloqueo.id_tramite">
            <td>{{ bloqueo.estado }}</td>
            <td>{{ bloqueo.capturista }}</td>
            <td>{{ bloqueo.fecha_mov }}</td>
            <td>{{ bloqueo.observa }}</td>
          </tr>
          <tr v-if="!bloqueos.length">
            <td colspan="4" class="text-center">Sin movimientos</td>
          </tr>
        </tbody>
      </table>
    </div>
    <!-- Bloquear Modal -->
    <div v-if="bloquearDialog" class="modal-backdrop">
      <div class="modal-dialog">
        <div class="modal-content">
          <div class="modal-header municipal-modal-header">
            <h5 class="modal-title text-white">
              <i class="fas fa-lock me-2"></i>Bloquear anuncio
            </h5>
            <button type="button" class="btn-close btn-close-white" @click="bloquearDialog = false"></button>
          </div>
          <div class="modal-body">
            <label>Motivo/Observaciones:</label>
            <input v-model="motivoBloqueo" type="text" class="form-control" />
          </div>
          <div class="modal-footer">
            <div class="btn-group municipal-group-btn" role="group">
              <button class="btn btn-outline-secondary" @click="bloquearDialog = false">Cancelar</button>
              <button class="btn btn-outline-danger" @click="bloquearAnuncio">
                <i class="fas fa-lock me-1"></i>Bloquear
              </button>
            </div>
          </div>
        </div>
      </div>
    </div>
    <!-- Desbloquear Modal -->
    <div v-if="desbloquearDialog" class="modal-backdrop">
      <div class="modal-dialog">
        <div class="modal-content">
          <div class="modal-header municipal-modal-header">
            <h5 class="modal-title text-white">
              <i class="fas fa-unlock me-2"></i>Desbloquear anuncio
            </h5>
            <button type="button" class="btn-close btn-close-white" @click="desbloquearDialog = false"></button>
          </div>
          <div class="modal-body">
            <label>Motivo/Observaciones:</label>
            <input v-model="motivoDesbloqueo" type="text" class="form-control" />
          </div>
          <div class="modal-footer">
            <div class="btn-group municipal-group-btn" role="group">
              <button class="btn btn-outline-secondary" @click="desbloquearDialog = false">Cancelar</button>
              <button class="btn btn-outline-success" @click="desbloquearAnuncio">
                <i class="fas fa-unlock me-1"></i>Desbloquear
              </button>
            </div>
          </div>
        </div>
      </div>
    </div>
    <div v-if="mensaje" class="alert alert-info mt-3">{{ mensaje }}</div>
  </div>
</template>

<script>
export default {
  name: 'BloquearAnuncioPage',
  data() {
    return {
      numero_anuncio: '',
      anuncio: null,
      bloqueos: [],
      bloquearDialog: false,
      desbloquearDialog: false,
      motivoBloqueo: '',
      motivoDesbloqueo: '',
      mensaje: ''
    };
  },
  methods: {
    async buscarAnuncio() {
      this.mensaje = '';
      this.anuncio = null;
      this.bloqueos = [];
      if (!this.numero_anuncio) return;
      try {
        const res = await this.$axios.post('/api/execute', {
          action: 'licencias2.buscar_anuncio',
          payload: { numero_anuncio: this.numero_anuncio }
        });
        if (res.data.status === 'success' && res.data.data.length) {
          this.anuncio = res.data.data[0];
          await this.cargarBloqueos();
        } else {
          this.mensaje = 'No se encontró licencia con ese número';
        }
      } catch (error) {
        this.mensaje = 'Error al buscar anuncio';
      }
    },
    async cargarBloqueos() {
      if (!this.anuncio) return;
      try {
        const res = await this.$axios.post('/api/execute', {
          action: 'licencias2.consultar_bloqueos',
          payload: { id_anuncio: this.anuncio.id_anuncio }
        });
        if (res.data.status === 'success') {
          this.bloqueos = res.data.data;
        } else {
          this.bloqueos = [];
        }
      } catch (error) {
        this.bloqueos = [];
      }
    },
    async bloquearAnuncio() {
      if (!this.anuncio || this.anuncio.bloqueado) return;
      try {
        const res = await this.$axios.post('/api/execute', {
          action: 'licencias2.bloquear_anuncio',
          payload: {
            id_anuncio: this.anuncio.id_anuncio,
            observa: this.motivoBloqueo,
            usuario: this.usuarioActual()
          }
        });
        this.bloquearDialog = false;
        if (res.data.status === 'success') {
          this.mensaje = 'Anuncio bloqueado correctamente';
          await this.buscarAnuncio();
        } else {
          this.mensaje = res.data.message || 'Error al bloquear anuncio';
        }
      } catch (error) {
        this.mensaje = 'Error al bloquear anuncio';
        this.bloquearDialog = false;
      }
      this.motivoBloqueo = '';
    },
    async desbloquearAnuncio() {
      if (!this.anuncio || !this.anuncio.bloqueado) return;
      try {
        const res = await this.$axios.post('/api/execute', {
          action: 'licencias2.desbloquear_anuncio',
          payload: {
            id_anuncio: this.anuncio.id_anuncio,
            observa: this.motivoDesbloqueo,
            usuario: this.usuarioActual()
          }
        });
        this.desbloquearDialog = false;
        if (res.data.status === 'success') {
          this.mensaje = 'Anuncio desbloqueado correctamente';
          await this.buscarAnuncio();
        } else {
          this.mensaje = res.data.message || 'Error al desbloquear anuncio';
        }
      } catch (error) {
        this.mensaje = 'Error al desbloquear anuncio';
        this.desbloquearDialog = false;
      }
      this.motivoDesbloqueo = '';
    },
    usuarioActual() {
      // Reemplazar por lógica real de usuario autenticado
      return (window.user && window.user.username) || 'sistema';
    }
  }
};
</script>

<style scoped>
.bloquear-anuncio-page {
  max-width: 900px;
  margin: 0 auto;
  padding: 2rem 1rem;
  background: white;
  min-height: 100vh;
  font-family: var(--font-municipal);
}

/* Municipal Header */
.municipal-header {
  background: linear-gradient(135deg, var(--municipal-primary) 0%, var(--municipal-secondary) 100%);
  color: white;
  padding: 1.5rem 2rem;
  border-radius: var(--radius-lg);
  margin-bottom: 2rem;
  display: flex;
  align-items: center;
  box-shadow: var(--shadow-md);
}

.municipal-header h2 {
  margin: 0;
  font-weight: var(--font-weight-bold);
  font-size: 1.75rem;
}

/* Municipal Cards */
.municipal-card {
  background: white;
  border: none;
  border-radius: var(--radius-lg);
  box-shadow: var(--shadow-sm);
  border-top: 4px solid var(--municipal-primary);
  transition: var(--transition-normal);
}

.municipal-card:hover {
  box-shadow: var(--shadow-md);
  transform: translateY(-2px);
}

/* Municipal Button Groups */
.municipal-group-btn {
  box-shadow: var(--shadow-sm);
  border-radius: var(--radius-md);
}

.municipal-group-btn .btn {
  border: 1px solid var(--municipal-primary);
  font-weight: var(--font-weight-bold);
  transition: var(--transition-normal);
  font-family: var(--font-municipal);
}

.municipal-group-btn .btn-outline-primary {
  color: var(--municipal-primary);
  background: white;
}

.municipal-group-btn .btn-outline-primary:hover,
.municipal-group-btn .btn-outline-primary:focus {
  background: var(--municipal-primary);
  border-color: var(--municipal-primary);
  color: white;
  box-shadow: 0 0 0 0.2rem rgba(234, 130, 21, 0.25);
}

.municipal-group-btn .btn-outline-danger {
  color: var(--municipal-danger);
  border-color: var(--municipal-danger);
  background: white;
}

.municipal-group-btn .btn-outline-danger:hover,
.municipal-group-btn .btn-outline-danger:focus {
  background: var(--municipal-danger);
  border-color: var(--municipal-danger);
  color: white;
}

.municipal-group-btn .btn-outline-success {
  color: var(--municipal-success);
  border-color: var(--municipal-success);
  background: white;
}

.municipal-group-btn .btn-outline-success:hover,
.municipal-group-btn .btn-outline-success:focus {
  background: var(--municipal-success);
  border-color: var(--municipal-success);
  color: white;
}

.municipal-group-btn .btn-outline-secondary {
  color: var(--slate-600);
  border-color: var(--slate-300);
  background: white;
}

.municipal-group-btn .btn-outline-secondary:hover,
.municipal-group-btn .btn-outline-secondary:focus {
  background: var(--slate-100);
  border-color: var(--slate-400);
  color: var(--slate-700);
}

/* Municipal Tables */
.municipal-table {
  background: white;
  border-radius: var(--radius-md);
  overflow: hidden;
  box-shadow: var(--shadow-sm);
}

.municipal-table-header {
  background: linear-gradient(135deg, var(--municipal-primary) 0%, var(--municipal-secondary) 100%);
  color: white;
}

.municipal-table-header th {
  border: none;
  font-weight: var(--font-weight-bold);
  padding: 1rem;
  font-family: var(--font-municipal);
}

.municipal-table td {
  border: none;
  border-bottom: 1px solid var(--slate-100);
  padding: 0.75rem 1rem;
  transition: var(--transition-normal);
}

.municipal-table tr:hover td {
  background-color: var(--slate-50);
}

.municipal-table tr:last-child td {
  border-bottom: none;
}

/* Municipal Modals */
.municipal-modal-header {
  background: linear-gradient(135deg, var(--municipal-primary) 0%, var(--municipal-secondary) 100%);
  border: none;
  border-radius: var(--radius-lg) var(--radius-lg) 0 0;
}

.modal-backdrop {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(0, 0, 0, 0.5);
  z-index: 1050;
  display: flex;
  align-items: center;
  justify-content: center;
  backdrop-filter: blur(4px);
}

.modal-dialog {
  min-width: 400px;
  margin: 1rem;
}

.modal-content {
  border: none;
  border-radius: var(--radius-lg);
  box-shadow: var(--shadow-xl);
}

/* Form Controls */
.form-control {
  border: 2px solid var(--slate-200);
  border-radius: var(--radius-md);
  padding: 0.75rem 1rem;
  font-family: var(--font-municipal);
  transition: var(--transition-normal);
}

.form-control:focus {
  border-color: var(--municipal-primary);
  box-shadow: 0 0 0 0.2rem rgba(234, 130, 21, 0.25);
  outline: none;
}

/* Status Colors */
.text-danger {
  color: var(--municipal-danger) !important;
  font-weight: var(--font-weight-bold);
}

.text-success {
  color: var(--municipal-success) !important;
  font-weight: var(--font-weight-bold);
}

/* Alert Styling */
.alert {
  border: none;
  border-radius: var(--radius-md);
  border-left: 4px solid var(--municipal-info);
  background: var(--slate-50);
  color: var(--slate-700);
  font-family: var(--font-municipal);
}

/* Responsive */
@media (max-width: 768px) {
  .bloquear-anuncio-page {
    padding: 1rem 0.5rem;
  }

  .municipal-header {
    padding: 1rem;
    text-align: center;
  }

  .municipal-header h2 {
    font-size: 1.5rem;
  }

  .btn-group {
    display: flex;
    flex-direction: column;
    width: 100%;
  }

  .btn-group .btn {
    border-radius: var(--radius-md) !important;
    margin-bottom: 0.5rem;
  }

  .modal-dialog {
    min-width: auto;
    width: 95%;
    margin: 1rem auto;
  }
}
</style>
