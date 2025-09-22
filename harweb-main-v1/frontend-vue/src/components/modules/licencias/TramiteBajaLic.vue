<template>
  <div class="tramite-baja-lic-page">
    <h1>Trámite de Baja de Licencia</h1>
    <div v-if="loading" class="loading">Cargando...</div>
    <div v-else>
      <form @submit.prevent="onBuscar">
        <label>No. de Licencia:
          <input v-model="form.licencia" type="text" required />
        </label>
        <button type="submit">Buscar</button>
      </form>
      <div v-if="licenciaData">
        <section class="licencia-info">
          <h2>Datos de la Licencia</h2>
          <p><strong>Propietario:</strong> {{ licenciaData.propietarionvo }}</p>
          <p><strong>Ubicación:</strong> {{ licenciaData.ubicacion }}</p>
          <p><strong>Actividad:</strong> {{ licenciaData.actividad }}</p>
          <p><strong>Sup. Construida:</strong> {{ licenciaData.sup_construida }}</p>
          <p><strong>Sup. Autorizada:</strong> {{ licenciaData.sup_autorizada }}</p>
          <p><strong>Num. Cajones:</strong> {{ licenciaData.num_cajones }}</p>
          <p><strong>Num. Empleados:</strong> {{ licenciaData.num_empleados }}</p>
          <p><strong>Vigente:</strong> {{ licenciaData.vigente }}</p>
        </section>
        <section class="adeudos">
          <h2>Adeudos</h2>
          <table>
            <thead>
              <tr>
                <th>Año</th>
                <th>Formas</th>
                <th>Derechos</th>
                <th>Recargos</th>
                <th>Gastos</th>
                <th>Multas</th>
                <th>Saldo</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="ad in licenciaData.adeudos" :key="ad.axo">
                <td>{{ ad.axo }}</td>
                <td>{{ ad.formas }}</td>
                <td>{{ ad.derechos }}</td>
                <td>{{ ad.recargos }}</td>
                <td>{{ ad.gastos }}</td>
                <td>{{ ad.multas }}</td>
                <td>{{ ad.saldo }}</td>
              </tr>
            </tbody>
          </table>
        </section>
        <section class="tramites-realizados">
          <h2>Trámites Realizados</h2>
          <table>
            <thead>
              <tr>
                <th>Año</th>
                <th>Folio</th>
                <th>Motivo</th>
                <th>Fecha Baja Admva</th>
                <th>Total</th>
                <th>Usuario</th>
                <th>Fecha</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="tr in licenciaData.tramites || []" :key="tr.folio">
                <td>{{ tr.axo }}</td>
                <td>{{ tr.folio }}</td>
                <td>{{ tr.motivo }}</td>
                <td>{{ tr.baja_admva }}</td>
                <td>{{ tr.total }}</td>
                <td>{{ tr.usuario }}</td>
                <td>{{ tr.fecha }}</td>
              </tr>
            </tbody>
          </table>
        </section>
        <section class="tramite-baja-form">
          <h2>Tramitar Baja</h2>
          <form @submit.prevent="onTramitarBaja">
            <label>Motivo de la baja:
              <input v-model="form.motivo" type="text" required />
            </label>
            <label>Fecha Baja Administrativa:
              <input v-model="form.baja_admva" type="date" required />
            </label>
            <button type="submit" :disabled="tramiteEnCurso">Tramitar Baja</button>
          </form>
        </section>
        <section class="acciones">
          <button @click="onAgregarTramite">Agregar Trámite</button>
          <button @click="onRecalcular">Recalcular Proporcional</button>
          <button @click="onImprimirOrden">Imprimir Orden de Pago</button>
        </section>
        <div v-if="mensaje" class="mensaje">{{ mensaje }}</div>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'TramiteBajaLic',
  data() {
    return {
      form: {
        licencia: '',
        motivo: '',
        baja_admva: '',
      },
      licenciaData: null,
      loading: false,
      mensaje: '',
      tramiteEnCurso: false
    };
  },
  methods: {
    async onBuscar() {
      this.loading = true;
      this.mensaje = '';
      this.licenciaData = null;
      try {
        const res = await this.$axios.post('/api/execute', {
          eRequest: {
            action: 'consultar',
            params: { licencia: this.form.licencia }
          }
        });
        if (res.data.eResponse.success) {
          this.licenciaData = res.data.eResponse.data;
        } else {
          this.mensaje = res.data.eResponse.message;
        }
      } catch (e) {
        this.mensaje = 'Error de comunicación con el servidor';
      }
      this.loading = false;
    },
    async onAgregarTramite() {
      this.form.motivo = '';
      this.form.baja_admva = '';
      this.mensaje = '';
      this.tramiteEnCurso = false;
    },
    async onTramitarBaja() {
      if (!this.form.licencia || !this.form.motivo || !this.form.baja_admva) {
        this.mensaje = 'Todos los campos son obligatorios';
        return;
      }
      this.tramiteEnCurso = true;
      try {
        const res = await this.$axios.post('/api/execute', {
          eRequest: {
            action: 'tramitar_baja',
            params: {
              licencia: this.form.licencia,
              motivo: this.form.motivo,
              baja_admva: this.form.baja_admva,
              usuario: this.$store.state.usuario
            }
          }
        });
        if (res.data.eResponse.success) {
          this.mensaje = 'Trámite de baja realizado correctamente';
          this.onBuscar();
        } else {
          this.mensaje = res.data.eResponse.message;
        }
      } catch (e) {
        this.mensaje = 'Error al tramitar baja';
      }
      this.tramiteEnCurso = false;
    },
    async onRecalcular() {
      this.mensaje = '';
      try {
        const res = await this.$axios.post('/api/execute', {
          eRequest: {
            action: 'recalcular',
            params: { licencia: this.form.licencia }
          }
        });
        if (res.data.eResponse.success) {
          this.mensaje = 'Recalculo realizado';
          this.onBuscar();
        } else {
          this.mensaje = res.data.eResponse.message;
        }
      } catch (e) {
        this.mensaje = 'Error al recalcular';
      }
    },
    async onImprimirOrden() {
      this.mensaje = '';
      try {
        const folio = this.licenciaData && this.licenciaData.tramites && this.licenciaData.tramites[0] ? this.licenciaData.tramites[0].folio : null;
        if (!folio) {
          this.mensaje = 'No hay folio para imprimir';
          return;
        }
        const res = await this.$axios.post('/api/execute', {
          eRequest: {
            action: 'imprimir_orden',
            params: { folio }
          }
        });
        if (res.data.eResponse.success) {
          window.open(res.data.eResponse.pdf_url, '_blank');
        } else {
          this.mensaje = res.data.eResponse.message;
        }
      } catch (e) {
        this.mensaje = 'Error al imprimir orden';
      }
    }
  }
};
</script>

<style scoped>
.tramite-baja-lic-page {
  max-width: 900px;
  margin: 0 auto;
  padding: 2rem;
}
.loading {
  color: #888;
}
.licencia-info, .adeudos, .tramites-realizados, .tramite-baja-form, .acciones {
  margin-bottom: 2rem;
}
table {
  width: 100%;
  border-collapse: collapse;
  margin-bottom: 1rem;
}
th, td {
  border: 1px solid #ccc;
  padding: 0.5rem;
  text-align: left;
}
.mensaje {
  color: #b00;
  font-weight: bold;
}
</style>
