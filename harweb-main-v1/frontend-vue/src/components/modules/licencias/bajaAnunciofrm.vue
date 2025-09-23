<template>
  <div class="baja-anuncio-page">
    <h1>Baja de Anuncio</h1>
    <form @submit.prevent="buscarAnuncio">
      <div class="form-group">
        <label for="anuncio">No. de anuncio:</label>
        <input v-model="form.anuncio" id="anuncio" type="number" required />
        <button type="submit">Buscar</button>
      </div>
    </form>
    <div v-if="anuncioData">
      <div class="info-block">
        <p><strong>Licencia de referencia:</strong> {{ anuncioData.id_licencia }}</p>
        <p><strong>Fecha de otorgamiento:</strong> {{ anuncioData.fecha_otorgamiento }}</p>
        <p><strong>Propietario:</strong> {{ anuncioData.propietarionvo }}</p>
        <p><strong>Medidas:</strong> {{ anuncioData.medidas1 }} x {{ anuncioData.medidas2 }}</p>
        <p><strong>Área:</strong> {{ anuncioData.area_anuncio }}</p>
        <p><strong>Ubicación:</strong> {{ anuncioData.ubicacion }} No. ext: {{ anuncioData.numext_ubic }} letra ext: {{ anuncioData.letraext_ubic }} No. int: {{ anuncioData.numint_ubic }} letra int: {{ anuncioData.letraint_ubic }}</p>
        <p><strong>Teléfono:</strong> {{ anuncioData.telefono_prop }}</p>
      </div>
      <div v-if="anuncioData.adeudos && anuncioData.adeudos.length">
        <div class="alert alert-danger">
          <strong>El anuncio cuenta con adeudo, no se podrá dar de baja.</strong>
        </div>
        <table class="table table-bordered">
          <thead>
            <tr><th>Año</th><th>Saldo</th></tr>
          </thead>
          <tbody>
            <tr v-for="row in anuncioData.adeudos" :key="row.axo">
              <td>{{ row.axo }}</td>
              <td>{{ row.saldo }}</td>
            </tr>
          </tbody>
        </table>
      </div>
      <div v-if="anuncioData.vigente !== 'V'">
        <div class="alert alert-warning">El anuncio ya se encuentra cancelado.</div>
      </div>
      <form v-if="anuncioData.vigente === 'V' && (!anuncioData.adeudos || anuncioData.adeudos.length === 0)" @submit.prevent="bajaAnuncio">
        <div class="form-group">
          <label for="motivo">Motivo de la baja:</label>
          <input v-model="form.motivo" id="motivo" type="text" />
        </div>
        <div class="form-row">
          <label><input type="checkbox" v-model="form.baja_error" /> Baja por error</label>
          <label><input type="checkbox" v-model="form.baja_tiempo" /> Baja en tiempo</label>
        </div>
        <div class="form-row" v-if="!form.baja_error && !form.baja_tiempo">
          <label for="axo_baja">Año:</label>
          <input v-model="form.axo_baja" id="axo_baja" type="number" required />
          <label for="folio_baja">Folio:</label>
          <input v-model="form.folio_baja" id="folio_baja" type="number" required />
        </div>
        <button type="submit" :disabled="bajaProcesando">Dar de baja</button>
      </form>
      <div v-if="bajaResult && bajaResult.status === 'ok'" class="alert alert-success">
        Baja realizada correctamente.
      </div>
      <div v-if="bajaResult && bajaResult.status === 'error'" class="alert alert-danger">
        <div v-for="err in bajaResult.errors" :key="err">{{ err }}</div>
      </div>
    </div>
    <div v-if="error" class="alert alert-danger">{{ error }}</div>
  </div>
</template>

<script>
export default {
  name: 'BajaAnuncioPage',
  data() {
    return {
      form: {
        anuncio: '',
        motivo: '',
        axo_baja: '',
        folio_baja: '',
        baja_error: false,
        baja_tiempo: false
      },
      anuncioData: null,
      bajaResult: null,
      bajaProcesando: false,
      error: null
    }
  },
  methods: {
    async buscarAnuncio() {
      this.error = null;
      this.anuncioData = null;
      this.bajaResult = null;
      try {
        const res = await fetch('/api/execute', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            eRequest: {
              action: 'buscar_anuncio',
              params: { anuncio: this.form.anuncio },
              user: this.$store.state.user
            }
          })
        });
        const json = await res.json();
        if (json.eResponse.status === 'ok' && json.eResponse.data.length > 0) {
          this.anuncioData = json.eResponse.data[0];
        } else {
          this.error = 'No se encontró el anuncio.';
        }
      } catch (e) {
        this.error = e.message;
      }
    },
    async bajaAnuncio() {
      this.bajaProcesando = true;
      this.bajaResult = null;
      try {
        const res = await fetch('/api/execute', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            eRequest: {
              action: 'baja_anuncio',
              params: {
                anuncio: this.form.anuncio,
                motivo: this.form.motivo,
                axo_baja: this.form.axo_baja,
                folio_baja: this.form.folio_baja,
                usuario: this.$store.state.user,
                baja_error: this.form.baja_error,
                baja_tiempo: this.form.baja_tiempo
              },
              user: this.$store.state.user
            }
          })
        });
        const json = await res.json();
        this.bajaResult = json.eResponse;
        if (json.eResponse.status === 'ok') {
          this.buscarAnuncio();
        }
      } catch (e) {
        this.bajaResult = { status: 'error', errors: [e.message] };
      } finally {
        this.bajaProcesando = false;
      }
    }
  }
}
</script>

<style scoped>
.baja-anuncio-page {
  max-width: 700px;
  margin: 0 auto;
  padding: 2rem;
}
.info-block {
  background: #f8f8f8;
  padding: 1rem;
  margin-bottom: 1rem;
  border-radius: 4px;
}
.alert {
  margin: 1rem 0;
}
.form-group, .form-row {
  margin-bottom: 1rem;
}
</style>
