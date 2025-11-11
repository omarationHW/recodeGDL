<template>
  <div class="aplica-pgo-divadmin-page">
    <nav aria-label="breadcrumb">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">Aplica Pagos Diversos Admin</li>
      </ol>
    </nav>
    <h2>Aplica Pagos de Diversos en Admin</h2>
    <div class="form-section">
      <div class="form-group">
        <label>Buscar por:</label>
        <div>
          <label><input type="radio" value="0" v-model="opcion" @change="onOpcionChange"> Por Placa</label>
          <label><input type="radio" value="1" v-model="opcion" @change="onOpcionChange"> Por Placa y Folio</label>
          <label><input type="radio" value="2" v-model="opcion" @change="onOpcionChange"> Por Año y Folio</label>
        </div>
      </div>
      <div class="form-row">
        <div v-if="opcion == 0 || opcion == 1" class="form-group">
          <label>Placa</label>
          <input type="text" v-model="form.placa" maxlength="7" class="form-control text-uppercase" />
        </div>
        <div v-if="opcion == 2" class="form-group">
          <label>Año</label>
          <input type="text" v-model="form.axo" maxlength="4" class="form-control" />
        </div>
        <div v-if="opcion == 1 || opcion == 2" class="form-group">
          <label>Folio</label>
          <input type="text" v-model="form.folio" maxlength="7" class="form-control" />
        </div>
        <div class="form-group align-bottom">
          <button class="btn btn-primary" @click="buscarFolios">Buscar</button>
          <button class="btn btn-secondary ml-2" @click="resetForm">Limpiar</button>
          <button class="btn btn-danger ml-2" @click="$router.back()">Salir</button>
        </div>
      </div>
    </div>
    <div v-if="folios.length > 0" class="result-section mt-4">
      <h4>Folios encontrados</h4>
      <table class="table table-bordered table-sm">
        <thead>
          <tr>
            <th></th>
            <th>Año</th>
            <th>Folio</th>
            <th>Placa</th>
            <th>Fecha Folio</th>
            <th>Estado</th>
            <th>Infracción</th>
            <th>Tarifa</th>
            <th>Descripción</th>
            <th>Pago</th>
            <th>Usuario Inicial</th>
            <th>Notif</th>
            <th>Num Acuerdo</th>
            <th>Costo Fijo</th>
            <th>Ord</th>
            <th>Afec</th>
            <th>Zona</th>
            <th>Espacio</th>
            <th>Fecha Baja</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="(folio, idx) in folios" :key="idx">
            <td><input type="checkbox" v-model="folio.selected" /></td>
            <td>{{ folio.axo }}</td>
            <td>{{ folio.folio }}</td>
            <td>{{ folio.placa }}</td>
            <td>{{ folio.fecha_folio }}</td>
            <td>{{ folio.estado }}</td>
            <td>{{ folio.infraccion }}</td>
            <td>{{ folio.tarifa }}</td>
            <td>{{ folio.descripcion }}</td>
            <td>{{ folio.pago }}</td>
            <td>{{ folio.usu_inicial }}</td>
            <td>{{ folio.notif }}</td>
            <td>{{ folio.num_acuerdo }}</td>
            <td>{{ folio.costo_fijo01 }}</td>
            <td>{{ folio.ord }}</td>
            <td>{{ folio.afec }}</td>
            <td>{{ folio.zona }}</td>
            <td>{{ folio.espacio }}</td>
            <td>{{ folio.fecha_baja }}</td>
          </tr>
        </tbody>
      </table>
      <button class="btn btn-success mt-2" @click="abrirPagoDiversos">Aplicar Pago Diversos</button>
    </div>
    <div v-if="showPagoDiversos" class="modal-mask">
      <div class="modal-wrapper">
        <div class="modal-container">
          <h5>Pago realizado por DIVERSOS ADMIN</h5>
          <div class="form-group">
            <label>Fecha de Pago</label>
            <input type="date" v-model="pago.fecha" class="form-control" />
          </div>
          <div class="form-group">
            <label>Recaudadora</label>
            <select v-model="pago.reca" class="form-control">
              <option v-for="rec in recaudadoras" :key="rec.id_rec" :value="rec.id_rec">
                {{ rec.id_rec.toString().padStart(2, '0') }} - {{ rec.recaudadora }}
              </option>
            </select>
          </div>
          <div class="form-group">
            <label>Caja</label>
            <input type="text" v-model="pago.caja" maxlength="2" class="form-control" />
          </div>
          <div class="form-group">
            <label>Consec. de Oper.</label>
            <input type="text" v-model="pago.oper" maxlength="10" class="form-control" />
          </div>
          <div class="form-group text-right">
            <button class="btn btn-primary" @click="aplicarPagos">Continuar</button>
            <button class="btn btn-secondary ml-2" @click="showPagoDiversos=false">Cancelar</button>
          </div>
        </div>
      </div>
    </div>
    <div v-if="mensaje" class="alert alert-info mt-3">{{ mensaje }}</div>
  </div>
</template>

<script>
export default {
  name: 'AplicaPgoDivAdmin',
  data() {
    return {
      opcion: '0',
      form: {
        placa: '',
        axo: '',
        folio: ''
      },
      folios: [],
      recaudadoras: [],
      showPagoDiversos: false,
      pago: {
        fecha: '',
        reca: '',
        caja: '',
        oper: ''
      },
      mensaje: ''
    };
  },
  mounted() {
    this.cargarRecaudadoras();
    this.pago.fecha = new Date().toISOString().substr(0, 10);
  },
  methods: {
    onOpcionChange() {
      this.form.placa = '';
      this.form.axo = '';
      this.form.folio = '';
    },
    async cargarRecaudadoras() {
      try {
        const res = await this.$axios.post('/api/execute', {
          action: 'estacionamientos.getRecaudadoras'
        });
        if (res.data.status === 'success') {
          this.recaudadoras = res.data.data;
          if (this.recaudadoras.length > 0) {
            this.pago.reca = this.recaudadoras[0].id_rec;
          }
        }
      } catch (error) {
        console.error('Error cargando recaudadoras:', error);
      }
    },
    async buscarFolios() {
      this.mensaje = '';
      let payload = {
        opcion: parseInt(this.opcion),
        placa: this.form.placa.trim(),
        folio: this.form.folio.trim(),
        axo: this.form.axo.trim()
      };
      try {
        const res = await this.$axios.post('/api/execute', {
          action: 'estacionamientos.buscarFolios',
          payload
        });
        if (res.data.status === 'success') {
          this.folios = res.data.data.map(f => ({ ...f, selected: false }));
          if (this.folios.length === 0) {
            this.mensaje = 'No se encontraron registros.';
          }
        } else {
          this.mensaje = res.data.message;
        }
      } catch (error) {
        this.mensaje = 'Error de conexión con el servidor';
      }
    },
    resetForm() {
      this.form.placa = '';
      this.form.axo = '';
      this.form.folio = '';
      this.folios = [];
      this.mensaje = '';
    },
    abrirPagoDiversos() {
      if (!this.folios.some(f => f.selected)) {
        this.mensaje = 'Debe seleccionar al menos un folio.';
        return;
      }
      this.showPagoDiversos = true;
    },
    async aplicarPagos() {
      this.mensaje = '';
      let foliosSeleccionados = this.folios.filter(f => f.selected).map(f => ({ axo: f.axo, folio: f.folio }));
      if (foliosSeleccionados.length === 0) {
        this.mensaje = 'Debe seleccionar al menos un folio.';
        return;
      }
      let payload = {
        folios: foliosSeleccionados,
        fecha: this.pago.fecha,
        reca: this.pago.reca,
        caja: this.pago.caja,
        oper: this.pago.oper,
        usuario: 'usuario_actual' // Reemplazar por usuario real
      };
      try {
        const res = await this.$axios.post('/api/execute', {
          action: 'estacionamientos.aplicarPagosDiversosAdmin',
          payload
        });
        if (res.data.status === 'success') {
          this.mensaje = res.data.message;
          this.showPagoDiversos = false;
          this.buscarFolios();
        } else {
          this.mensaje = res.data.message;
        }
      } catch (error) {
        this.mensaje = 'Error de conexión con el servidor';
      }
    }
  }
};
</script>

<style scoped>
.aplica-pgo-divadmin-page {
  max-width: 1200px;
  margin: 0 auto;
  padding: 2rem;
}
.form-section {
  background: #f8f9fa;
  padding: 1rem;
  border-radius: 6px;
}
.form-row {
  display: flex;
  flex-wrap: wrap;
  gap: 1rem;
  align-items: flex-end;
}
.form-group {
  margin-bottom: 1rem;
}
.align-bottom {
  align-self: flex-end;
}
.result-section {
  background: #fff;
  padding: 1rem;
  border-radius: 6px;
  box-shadow: 0 2px 8px #eee;
}
.modal-mask {
  position: fixed;
  z-index: 9998;
  top: 0; left: 0; right: 0; bottom: 0;
  background-color: rgba(0,0,0,0.5);
  display: flex;
  align-items: center;
  justify-content: center;
}
.modal-wrapper {
  width: 400px;
}
.modal-container {
  background: #fff;
  padding: 2rem;
  border-radius: 8px;
  box-shadow: 0 2px 8px #aaa;
}
</style>
