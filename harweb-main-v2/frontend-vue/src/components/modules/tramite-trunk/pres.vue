<template>
  <div class="prescripcion-page">
    <h1>Prescripción de Adeudos</h1>
    <div class="breadcrumb">
      <router-link to="/">Inicio</router-link> / Prescripción
    </div>
    <form @submit.prevent="buscar">
      <fieldset>
        <legend>Periodo a Prescribir</legend>
        <div class="row">
          <div class="col">
            <label>Año Inicial</label>
            <input v-model="form.axoini" type="number" min="1900" max="2100" required />
          </div>
          <div class="col">
            <label>Bimestre Inicial</label>
            <select v-model="form.bimini">
              <option v-for="b in 6" :key="b" :value="b">{{ b }}</option>
            </select>
          </div>
          <div class="col">
            <label>Año Final</label>
            <input v-model="form.axofin" type="number" min="1900" max="2100" required />
          </div>
          <div class="col">
            <label>Bimestre Final</label>
            <select v-model="form.bimfin">
              <option v-for="b in 6" :key="b" :value="b">{{ b }}</option>
            </select>
          </div>
        </div>
        <div class="row">
          <div class="col">
            <label>Cuenta Catastral</label>
            <input v-model="form.cvecuenta" type="number" required />
          </div>
          <div class="col">
            <button type="submit">Buscar</button>
          </div>
        </div>
      </fieldset>
    </form>
    <div v-if="saldos.length">
      <h2>Detalle de Saldos a Prescribir</h2>
      <table class="table table-bordered">
        <thead>
          <tr>
            <th>Año</th>
            <th>Bim</th>
            <th>Imp. Fact</th>
            <th>Imp. Pag</th>
            <th>Desc. Impto</th>
            <th>Imp. Adeudado</th>
            <th>Rec. Fact</th>
            <th>Rec. Pag</th>
            <th>Desc. Rec</th>
            <th>Saldo</th>
            <th>C. Min</th>
            <th>Exento</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="row in saldos" :key="row.cvecuenta + '-' + row.axosal + '-' + row.bimsal">
            <td>{{ row.axosal }}</td>
            <td>{{ row.bimsal }}</td>
            <td>{{ row.impfac }}</td>
            <td>{{ row.imppag }}</td>
            <td>{{ row.impvir }}</td>
            <td>{{ row.impade }}</td>
            <td>{{ row.recfac }}</td>
            <td>{{ row.recpag }}</td>
            <td>{{ row.recvir }}</td>
            <td>{{ row.saldo }}</td>
            <td>{{ row.cuotamin }}</td>
            <td>{{ row.exento }}</td>
          </tr>
        </tbody>
      </table>
      <form @submit.prevent="prescribir">
        <div class="form-group">
          <label>Observaciones</label>
          <textarea v-model="form.observacion" rows="3" class="form-control"></textarea>
        </div>
        <div class="form-group">
          <label>Usuario</label>
          <input v-model="form.usuario" type="text" required />
        </div>
        <button type="submit">Prescribir</button>
      </form>
    </div>
    <div v-if="message" class="alert" :class="{'alert-success': success, 'alert-danger': !success}">
      {{ message }}
    </div>
  </div>
</template>

<script>
export default {
  name: 'PrescripcionPage',
  data() {
    return {
      form: {
        cvecuenta: '',
        axoini: '',
        bimini: 1,
        axofin: '',
        bimfin: 1,
        observacion: '',
        usuario: ''
      },
      saldos: [],
      message: '',
      success: false
    };
  },
  methods: {
    async buscar() {
      this.message = '';
      this.saldos = [];
      try {
        const res = await fetch('/api/execute', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            eRequest: {
              action: 'search',
              data: {
                cvecuenta: this.form.cvecuenta,
                axoini: this.form.axoini,
                bimini: this.form.bimini,
                axofin: this.form.axofin,
                bimfin: this.form.bimfin
              }
            }
          })
        });
        const json = await res.json();
        if (json.eResponse.success) {
          this.saldos = json.eResponse.data;
          this.message = json.eResponse.message;
          this.success = true;
        } else {
          this.message = json.eResponse.message;
          this.success = false;
        }
      } catch (e) {
        this.message = 'Error de comunicación con el servidor';
        this.success = false;
      }
    },
    async prescribir() {
      try {
        const res = await fetch('/api/execute', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            eRequest: {
              action: 'save',
              data: {
                cvecuenta: this.form.cvecuenta,
                axoini: this.form.axoini,
                bimini: this.form.bimini,
                axofin: this.form.axofin,
                bimfin: this.form.bimfin,
                observacion: this.form.observacion,
                usuario: this.form.usuario
              }
            }
          })
        });
        const json = await res.json();
        if (json.eResponse.success) {
          this.message = json.eResponse.message;
          this.success = true;
          this.saldos = [];
        } else {
          this.message = json.eResponse.message;
          this.success = false;
        }
      } catch (e) {
        this.message = 'Error de comunicación con el servidor';
        this.success = false;
      }
    }
  }
};
</script>

<style scoped>
.prescripcion-page {
  max-width: 900px;
  margin: 0 auto;
  padding: 2rem;
}
.breadcrumb {
  margin-bottom: 1rem;
}
.row {
  display: flex;
  gap: 1rem;
  margin-bottom: 1rem;
}
.col {
  flex: 1;
}
.table {
  width: 100%;
  margin-bottom: 1rem;
}
.alert {
  margin-top: 1rem;
  padding: 1rem;
}
.alert-success {
  background: #e0ffe0;
  color: #1a4d1a;
}
.alert-danger {
  background: #ffe0e0;
  color: #a11a1a;
}
</style>
