<template>
  <div class="reactiva-tramite-page">
    <nav aria-label="breadcrumb" class="mb-3">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">Reactivación de Trámites</li>
      </ol>
    </nav>
    <h2 class="mb-4">Reactivación de Trámites</h2>
    <div class="card mb-4">
      <div class="card-body">
        <form @submit.prevent="buscarTramite">
          <div class="form-group row">
            <label class="col-sm-2 col-form-label">No. de trámite:</label>
            <div class="col-sm-4">
              <input type="number" v-model="idTramite" class="form-control" required autofocus @keyup.enter="buscarTramite" />
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
          <div class="col-sm-5">{{ tramite.descripcion_giro }}</div>
        </div>
        <div class="row mb-2">
          <div class="col-sm-2 font-weight-bold">Actividad:</div>
          <div class="col-sm-10">{{ tramite.actividad }}</div>
        </div>
        <div class="row mb-2">
          <div class="col-sm-3 font-weight-bold">Sup. construida:</div>
          <div class="col-sm-2">{{ tramite.sup_construida }}</div>
          <div class="col-sm-3 font-weight-bold">Sup. autorizada:</div>
          <div class="col-sm-2">{{ tramite.sup_autorizada }}</div>
          <div class="col-sm-2 font-weight-bold">Num. cajones:</div>
          <div class="col-sm-2">{{ tramite.num_cajones }}</div>
          <div class="col-sm-2 font-weight-bold">Num. empleados:</div>
          <div class="col-sm-2">{{ tramite.num_empleados }}</div>
        </div>
        <div class="row mb-2">
          <div class="col-sm-2 font-weight-bold">Propietario:</div>
          <div class="col-sm-10">{{ propietarioCompleto }}</div>
        </div>
        <div class="row mb-2">
          <div class="col-sm-2 font-weight-bold">Ubicación:</div>
          <div class="col-sm-4">{{ tramite.ubicacion }}</div>
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
            <button class="btn btn-success" :disabled="!puedeReactivar" @click="abrirModalReactivar">Reactivar</button>
          </div>
        </div>
        <div v-if="tramite.estatus === 'A'" class="alert alert-info mt-3">
          El trámite ya se encuentra aprobado. No se puede reactivar.
        </div>
        <div v-else-if="tramite.estatus !== 'C' && tramite.estatus !== 'R'" class="alert alert-warning mt-3">
          El trámite no se encuentra cancelado o rechazado. No se puede reactivar.
        </div>
      </div>
    </div>
    <!-- Modal Motivo -->
    <div class="modal fade" tabindex="-1" role="dialog" :class="{show: showModal}" style="display: block;" v-if="showModal">
      <div class="modal-dialog" role="document">
        <div class="modal-content">
          <div class="modal-header">
            <h5 class="modal-title">Motivo de Reactivación</h5>
            <button type="button" class="close" @click="cerrarModal" aria-label="Close">
              <span aria-hidden="true">&times;</span>
            </button>
          </div>
          <div class="modal-body">
            <div class="form-group">
              <label>Ingrese el motivo de la reactivación:</label>
              <textarea v-model="motivo" class="form-control" rows="3"></textarea>
            </div>
          </div>
          <div class="modal-footer">
            <button type="button" class="btn btn-secondary" @click="cerrarModal">Cancelar</button>
            <button type="button" class="btn btn-primary" @click="reactivarTramite">Reactivar</button>
          </div>
        </div>
      </div>
    </div>
    <!-- Mensaje -->
    <div v-if="mensaje" class="alert mt-3" :class="{'alert-success': exito, 'alert-danger': !exito}">
      {{ mensaje }}
    </div>
  </div>
</template>

<script>
export default {
  name: 'ReactivaTramite',
  data() {
    return {
      idTramite: '',
      tramite: null,
      showModal: false,
      motivo: '',
      mensaje: '',
      exito: false
    };
  },
  computed: {
    propietarioCompleto() {
      if (!this.tramite) return '';
      return [this.tramite.primer_ap, this.tramite.segundo_ap, this.tramite.propietario].filter(Boolean).join(' ');
    },
    puedeReactivar() {
      if (!this.tramite) return false;
      return (this.tramite.estatus === 'C' || this.tramite.estatus === 'R');
    }
  },
  methods: {
    async buscarTramite() {
      this.mensaje = '';
      this.tramite = null;
      if (!this.idTramite) return;
      try {
        const eRequest = {
          action: 'licencias2.get_tramite',
          payload: { id_tramite: this.idTramite }
        };
        const response = await fetch('http://localhost:8000/api/generic', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json'
          },
          body: JSON.stringify({ eRequest })
        });
        const res = await response.json();
        if (res.status === 'success' && res.eResponse.data.result) {
          this.tramite = res.eResponse.data.result;
        } else {
          this.mensaje = res.message || 'Trámite no encontrado';
          this.exito = false;
        }
      } catch (error) {
        this.mensaje = 'Error al buscar trámite';
        this.exito = false;
      }
    },
    abrirModalReactivar() {
      this.motivo = '';
      this.showModal = true;
    },
    cerrarModal() {
      this.showModal = false;
    },
    async reactivarTramite() {
      if (!this.motivo.trim()) {
        alert('Debe ingresar un motivo');
        return;
      }
      try {
        const eRequest = {
          action: 'licencias2.reactivar_tramite',
          payload: {
            id_tramite: this.idTramite,
            motivo: this.motivo
          }
        };
        const response = await fetch('http://localhost:8000/api/generic', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json'
          },
          body: JSON.stringify({ eRequest })
        });
        const res = await response.json();
        this.mensaje = res.message;
        this.exito = res.status === 'success';
        if (res.status === 'success') {
          this.buscarTramite();
        }
      } catch (error) {
        this.mensaje = 'Error al reactivar trámite';
        this.exito = false;
      }
      this.cerrarModal();
    }
  }
};
</script>

<style scoped>
.reactiva-tramite-page {
  max-width: 900px;
  margin: 0 auto;
}
.modal {
  display: block;
  background: rgba(0,0,0,0.5);
}
.modal-dialog {
  margin-top: 10vh;
}
</style>
