<template>
  <div class="bloquear-anuncio-page">
    <nav aria-label="breadcrumb">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">Bloqueo de Anuncios</li>
      </ol>
    </nav>
    <h2 class="text-center">BLOQUEO DE ANUNCIOS</h2>
    <div class="card mb-3">
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
              <button type="submit" class="btn btn-primary mt-3">Buscar</button>
            </div>
          </div>
        </form>
      </div>
    </div>
    <div v-if="anuncio" class="card mb-3">
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
      <button class="btn btn-danger mr-2" :disabled="anuncio.bloqueado" @click="bloquearDialog = true">Bloquear anuncio</button>
      <button class="btn btn-success" :disabled="!anuncio.bloqueado" @click="desbloquearDialog = true">Desbloquear anuncio</button>
    </div>
    <div v-if="anuncio">
      <h5>Movimientos anteriores</h5>
      <table class="table table-bordered table-sm">
        <thead>
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
          <div class="modal-header">
            <h5 class="modal-title">Bloquear anuncio</h5>
            <button type="button" class="close" @click="bloquearDialog = false">&times;</button>
          </div>
          <div class="modal-body">
            <label>Motivo/Observaciones:</label>
            <input v-model="motivoBloqueo" type="text" class="form-control" />
          </div>
          <div class="modal-footer">
            <button class="btn btn-secondary" @click="bloquearDialog = false">Cancelar</button>
            <button class="btn btn-danger" @click="bloquearAnuncio">Bloquear</button>
          </div>
        </div>
      </div>
    </div>
    <!-- Desbloquear Modal -->
    <div v-if="desbloquearDialog" class="modal-backdrop">
      <div class="modal-dialog">
        <div class="modal-content">
          <div class="modal-header">
            <h5 class="modal-title">Desbloquear anuncio</h5>
            <button type="button" class="close" @click="desbloquearDialog = false">&times;</button>
          </div>
          <div class="modal-body">
            <label>Motivo/Observaciones:</label>
            <input v-model="motivoDesbloqueo" type="text" class="form-control" />
          </div>
          <div class="modal-footer">
            <button class="btn btn-secondary" @click="desbloquearDialog = false">Cancelar</button>
            <button class="btn btn-success" @click="desbloquearAnuncio">Desbloquear</button>
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
  padding: 2rem 0;
}
.modal-backdrop {
  position: fixed;
  top:0; left:0; right:0; bottom:0;
  background: rgba(0,0,0,0.3);
  z-index: 1050;
  display: flex;
  align-items: center;
  justify-content: center;
}
.modal-dialog {
  min-width: 400px;
}
</style>
