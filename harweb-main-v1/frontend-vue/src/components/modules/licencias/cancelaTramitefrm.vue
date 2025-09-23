<template>
  <div class="cancela-tramite-page">
    <nav aria-label="breadcrumb" class="mb-3">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">Cancelación de Trámites</li>
      </ol>
    </nav>
    <h2 class="mb-4">Cancelación de Trámites</h2>
    <div class="card mb-4">
      <div class="card-body">
        <form @submit.prevent="buscarTramite">
          <div class="form-group row">
            <label for="id_tramite" class="col-sm-2 col-form-label">No. de trámite:</label>
            <div class="col-sm-4">
              <input type="number" v-model="id_tramite" id="id_tramite" class="form-control" required @keyup.enter="buscarTramite" />
            </div>
            <div class="col-sm-2">
              <button type="submit" class="btn btn-primary">Buscar</button>
            </div>
          </div>
        </form>
      </div>
    </div>
    <div v-if="tramite" class="card mb-4">
      <div class="card-body">
        <div class="row mb-2">
          <div class="col-sm-3 font-weight-bold">Recaudadora:</div>
          <div class="col-sm-3">{{ tramite.recaud }}</div>
          <div class="col-sm-1 font-weight-bold">Giro:</div>
          <div class="col-sm-5">{{ giro.descripcion }}</div>
        </div>
        <div class="row mb-2">
          <div class="col-sm-2 font-weight-bold">Actividad:</div>
          <div class="col-sm-10">{{ tramite.actividad }}</div>
        </div>
        <div class="row mb-2">
          <div class="col-sm-2 font-weight-bold">Sup. construida:</div>
          <div class="col-sm-2">{{ tramite.sup_construida }}</div>
          <div class="col-sm-2 font-weight-bold">Sup. autorizada:</div>
          <div class="col-sm-2">{{ tramite.sup_autorizada }}</div>
          <div class="col-sm-2 font-weight-bold">Num. cajones:</div>
          <div class="col-sm-1">{{ tramite.num_cajones }}</div>
          <div class="col-sm-1 font-weight-bold">Num. empleados:</div>
          <div class="col-sm-2">{{ tramite.num_empleados }}</div>
        </div>
        <div class="row mb-2">
          <div class="col-sm-2 font-weight-bold">Propietario:</div>
          <div class="col-sm-10">{{ propietarioCompleto }}</div>
        </div>
        <div class="row mb-2">
          <div class="col-sm-2 font-weight-bold">Ubicación:</div>
          <div class="col-sm-3">{{ tramite.ubicacion }}</div>
          <div class="col-sm-1 font-weight-bold">No. ext.:</div>
          <div class="col-sm-1">{{ tramite.numext_ubic }}</div>
          <div class="col-sm-1 font-weight-bold">Letra ext.:</div>
          <div class="col-sm-1">{{ tramite.letraext_ubic }}</div>
          <div class="col-sm-1 font-weight-bold">No. int.:</div>
          <div class="col-sm-1">{{ tramite.numint_ubic }}</div>
          <div class="col-sm-1 font-weight-bold">Letra int.:</div>
          <div class="col-sm-1">{{ tramite.letraint_ubic }}</div>
        </div>
        <div class="row mt-3">
          <div class="col-sm-12">
            <button class="btn btn-danger" :disabled="!puedeCancelar" @click="abrirMotivo">Dar de baja</button>
          </div>
        </div>
      </div>
    </div>
    <div v-if="showMotivoModal" class="modal fade show d-block" tabindex="-1" role="dialog">
      <div class="modal-dialog" role="document">
        <div class="modal-content">
          <div class="modal-header">
            <h5 class="modal-title">Motivo de cancelación</h5>
            <button type="button" class="close" @click="cerrarMotivo" aria-label="Cerrar">
              <span aria-hidden="true">&times;</span>
            </button>
          </div>
          <div class="modal-body">
            <div class="form-group">
              <label for="motivo">Ingrese el motivo de la cancelación:</label>
              <textarea v-model="motivo" id="motivo" class="form-control" rows="3"></textarea>
            </div>
          </div>
          <div class="modal-footer">
            <button type="button" class="btn btn-secondary" @click="cerrarMotivo">Cancelar</button>
            <button type="button" class="btn btn-danger" @click="cancelarTramite">Confirmar Cancelación</button>
          </div>
        </div>
      </div>
      <div class="modal-backdrop fade show"></div>
    </div>
    <div v-if="mensaje" class="alert" :class="{'alert-success': mensajeTipo==='success', 'alert-danger': mensajeTipo==='error'}">
      {{ mensaje }}
    </div>
  </div>
</template>

<script>
export default {
  name: 'CancelaTramitePage',
  data() {
    return {
      id_tramite: '',
      tramite: null,
      giro: {},
      mensaje: '',
      mensajeTipo: '',
      showMotivoModal: false,
      motivo: '',
      loading: false
    };
  },
  computed: {
    propietarioCompleto() {
      if (!this.tramite) return '';
      return [
        this.tramite.primer_ap || '',
        this.tramite.segundo_ap || '',
        this.tramite.propietario || ''
      ].map(s => s.trim()).join(' ').replace(/\s+/g, ' ');
    },
    puedeCancelar() {
      if (!this.tramite) return false;
      if (this.tramite.estatus === 'C') return false;
      if (this.tramite.estatus === 'A') return false;
      return true;
    }
  },
  methods: {
    async buscarTramite() {
      this.mensaje = '';
      this.tramite = null;
      this.giro = {};
      if (!this.id_tramite) return;
      this.loading = true;
      try {
        // Buscar tramite
        const resp = await fetch('/api/execute', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ action: 'get_tramite_by_id', params: { id_tramite: this.id_tramite } })
        });
        const data = await resp.json();
        if (data.eResponse.success && data.eResponse.data.result && data.eResponse.data.result.length > 0) {
          this.tramite = data.eResponse.data.result[0];
          // Buscar giro
          if (this.tramite.id_giro) {
            const respGiro = await fetch('/api/execute', {
              method: 'POST',
              headers: { 'Content-Type': 'application/json' },
              body: JSON.stringify({ action: 'get_giro_by_id', params: { id_giro: this.tramite.id_giro } })
            });
            const dataGiro = await respGiro.json();
            if (dataGiro.success && dataGiro.data && dataGiro.data.length > 0) {
              this.giro = dataGiro.data[0];
            }
          }
        } else {
          this.mensaje = 'No se encontró el trámite.';
          this.mensajeTipo = 'error';
        }
      } catch (e) {
        this.mensaje = 'Error al buscar trámite.';
        this.mensajeTipo = 'error';
      } finally {
        this.loading = false;
      }
    },
    abrirMotivo() {
      this.motivo = '';
      this.showMotivoModal = true;
    },
    cerrarMotivo() {
      this.showMotivoModal = false;
    },
    async cancelarTramite() {
      if (!this.motivo.trim()) {
        this.mensaje = 'Debe ingresar el motivo de la cancelación.';
        this.mensajeTipo = 'error';
        return;
      }
      this.loading = true;
      try {
        const resp = await fetch('/api/execute', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            action: 'cancel_tramite',
            params: {
              id_tramite: this.tramite.id_tramite,
              motivo: this.motivo
            }
          })
        });
        const data = await resp.json();
        if (data.eResponse.success) {
          this.mensaje = 'Trámite cancelado exitosamente.';
          this.mensajeTipo = 'success';
          this.tramite.estatus = 'C';
        } else {
          this.mensaje = data.message || 'No se pudo cancelar el trámite.';
          this.mensajeTipo = 'error';
        }
      } catch (e) {
        this.mensaje = 'Error al cancelar trámite.';
        this.mensajeTipo = 'error';
      } finally {
        this.loading = false;
        this.showMotivoModal = false;
      }
    }
  }
};
</script>

<style scoped>
.cancela-tramite-page {
  max-width: 900px;
  margin: 0 auto;
  padding: 2rem 0;
}
.breadcrumb {
  background: none;
  padding-left: 0;
}
.modal-backdrop {
  position: fixed;
  top: 0; left: 0; right: 0; bottom: 0;
  background: rgba(0,0,0,0.5);
  z-index: 1040;
}
</style>
